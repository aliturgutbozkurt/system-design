#import "/template.typ": *

#show: doc => setup_book(title: "Ders 12: Dağıtık Hız Sınırlama (Rate Limiting): Token Bucket, Leaky Bucket, Sliding Window", doc)

#lesson_header(
  12,
  "Dağıtık Hız Sınırlama (Rate Limiting): Token Bucket, Leaky Bucket, Sliding Window",
  "Distributed Rate Limiting: Token Bucket, Leaky Bucket & Sliding Window",
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways"
)

#diagram_box[
```text
   [ 1. TOKEN BUCKET (Jeton Kovası) ]      [ 2. LEAKY BUCKET (Sızıntılı Kova) ]
        Jetonlar akar (Refill: 10/sn)          İstekler kovaya dolar (Burst)
             │                                       │
             ▼                                       ▼
        ┌─────────┐ (Kapasite: 50)             ┌───────────┐
        │ 🪙 🪙 🪙 │                              │ 💧 💧 💧  │
        └────┬────┘                            └─────┬─────┘
             ▼                                       ▼ Sabit Hızla Sızar (Leak)
        İstek gelince 1 jeton harcar!          Sabit debide işlenir (Smoothing)

   [ 3. SLIDING WINDOW LOG (Kayan Zaman Penceresi - Redis ZSET) ]
   Zaman:  [ 12:00:01 ]  [ 12:00:15 ]  [ 12:00:45 ]  --- (Limit: 1 dakikada 3 istek)
   Yeni İstek (12:00:55) -> Son 60 saniyedeki istekleri say -> 3 istek var -> 429 REDDİ!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir lunapark trenini düşünün: Trene binebilmek için jeton makinesinden jeton almalısınız (Token Bucket). Makine kovaya her saniye 2 yeni jeton atar; kova en fazla 10 jeton alır. Bir anda 10 kişi gelirse hepsi aynı anda trene biner (Burst). Ama 11. kişi kova dolana kadar kapıda beklemek zorundadır! Rate Limiter işte bu lunapark görevlisidir: Kötü niyetli bir robot veya aşırı heyecanlı bir kullanıcı saniyede 10.000 istek atarak sunucuyu çökertmesin diye 'Sakin ol, kotan doldu! (HTTP 429 Too Many Requests)' der!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine an amusement park roller coaster ride requiring tokens (Token Bucket). An automated dispenser drops 2 tokens into a bucket every second, up to a max capacity of 10. If a sudden group of 10 arrives, they grab all 10 tokens and board simultaneously (Burst). But person #11 must wait until new tokens drop! The Rate Limiter is that turnstile guard: shielding databases from aggressive bots or buggy loops by replying with HTTP 429 Too Many Requests!]
    ]
  )
]

#deep_dive_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("334155"), size: 9pt)[🇹🇷 MAANG DERİNLEMESİNE ANALİZ]\
      #v(3pt)
      MAANG mülakatlarında en çok sorulan 4 Rate Limiting algoritması: 1) Token Bucket: Amazon ve Stripe'ın tercihidir. Sabit hızda jeton dolar; burst (ani yük) trafiğe izin verir, bellek tüketimi azdır (sadece sayaç + zaman damgası). 2) Leaky Bucket: Trafiği sabit bir çıkış hızında düzleştirir (Traffic Shaping / Smoothing). 3) Fixed Window Counter: Zamanı sabit pencerelere böler (12:00-12:01); pencere sınırında iki katı istek geçmesine izin veren 'Window Boundary' açığı vardır. 4) Sliding Window Log / Counter: Redis `ZSET` veya bellek sayaçlarıyla kayan pencereyi milisaniye hassasiyetinde tutar; sınır açığını sıfırlar. Dağıtık ortamda Redis + Lua Scripting ile atomik olarak uygulanır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The 4 core rate limiting algorithms evaluated in MAANG rounds: 1) Token Bucket: Favored by Amazon/Stripe. Tokens replenish at a fixed rate; effortlessly absorbs short burst traffic with negligible memory (stores only timestamp + token count). 2) Leaky Bucket: Smooths bursty traffic into a constant outflow rate (vital for throttling queues). 3) Fixed Window Counter: Simple counter reset at window boundaries; vulnerable to 2x burst surges across the window boundary. 4) Sliding Window Counter: Blends historical and current window weights to neutralize boundary spikes with minimal Redis memory overhead. Implemented in distributed clusters via atomic Redis Lua scripts.]
    ]
  )
]

#java25_box[
```java
// Java 25: Thread-Safe Token Bucket Algoritması
import java.time.Instant;

public class TokenBucketRateLimiter {
    private final long capacity;
    private final double refillTokensPerSecond;
    private double availableTokens;
    private long lastRefillTimestamp;

    public TokenBucketRateLimiter(long capacity, double refillTokensPerSecond) {
        this.capacity = capacity;
        this.refillTokensPerSecond = refillTokensPerSecond;
        this.availableTokens = capacity;
        this.lastRefillTimestamp = System.currentTimeMillis();
    }

    public synchronized boolean tryAcquire() {
        refill();
        if (availableTokens >= 1.0) {
            availableTokens -= 1.0;
            return true; // İstek kabul edildi
        }
        return false; // HTTP 429 Too Many Requests
    }

    private void refill() {
        long now = System.currentTimeMillis();
        double elapsedSeconds = (now - lastRefillTimestamp) / 1000.0;
        availableTokens = Math.min(capacity, availableTokens + elapsedSeconds * refillTokensPerSecond);
        lastRefillTimestamp = now;
    }
}

void main() {
    var limiter = new TokenBucketRateLimiter(3, 1.0); // 3 kapasite, saniyede 1 jeton
    for (int i = 1; i <= 5; i++) {
        boolean allowed = limiter.tryAcquire();
        IO.println("İstek #" + i + " İzin Verildi mi? " + allowed);
    }
}
```
]

#warning_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("b45309"), size: 9pt)[🇹🇷 MÜLAKAT TUZAĞI VE DARBOĞAZ]\
      #v(3pt)
      Dağıtık ortamda her web sunucusunun kendi belleğinde local rate limiter tutması mülakatta eksi puandır! 10 sunucu varsa kullanıcı her sunucuya 100 istek atıp toplamda 1.000 istek yapabilir. Hız sınırlayıcı merkezi bir Redis kümesinde veya Envoy filter seviyesinde tutulmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Storing rate limit counters in local JVM memory fails in clustered deployments. 10 pods mean a user can fire 10x their quota via round-robin. Centralize distributed counters within a shared Redis cluster utilizing Lua scripts.]
    ]
  )
]

#takeaways_box((
    ("Token Bucket algoritması ani yükleri (bursts) tolere ettiği için endüstri standardıdır.", "Token Bucket is the industry standard because it gracefully accommodates bursty traffic spikes."),
    ("Dağıtık ortamlarda yarış durumunu (Race Condition) önlemek için Redis Lua Script kullanılır.", "Redis Lua scripts execute read-and-decrement steps atomically without distributed locks."),
    ("Kotası dolan istemciye HTTP 429 ve 'Retry-After: 30' yanıt başlığı dönülmelidir.", "Rate-limited clients must receive HTTP 429 along with a Retry-After header."),
))
