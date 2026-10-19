#import "/template.typ": *

#show: doc => setup_book(title: "Ders 39: Dağıtık Hız Sınırlayıcı (Distributed Rate Limiter) Tasarımı: Redis Lua ve Multi-Region", doc)

#lesson_header(
  39,
  "Dağıtık Hız Sınırlayıcı (Distributed Rate Limiter) Tasarımı: Redis Lua ve Multi-Region",
  "Designing a Distributed Rate Limiter: Redis Lua & Multi-Region",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ DAĞITIK RATE LIMITER - REDIS LUA MİMARİSİ ]

   İstemci ──▶ [ API GATEWAY / RATE LIMITER FILTER ]
                           │
                           ▼ Atomik EVALSHA (Tek Ağ Çağrısı!)
               ┌────────────────────────────────────────────────────────┐
               │ REDIS CLUSTER (LUA SCRIPT)                             │
               │ 1. local current = redis.call('get', KEYS[1])          │
               │ 2. if current and current > limit then return 0 end    │
               │ 3. redis.call('incr', KEYS[1])                         │
               │ 4. redis.call('expire', KEYS[1], ARGV[2]) return 1     │
               └────────────────────────────────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
        [ İzin Verildi ]          [ HTTP 429 REDDİ ]
     (Backend'e İletilir)      (Retry-After: 30 sn)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir gece kulübünün kapısındaki fedaiyi düşünün (Rate Limiter). Kulübün kuralı: 'Bir kişi dakikada en fazla 5 kez içeri girip çıkabilir'. Fedainin elinde telsizle bağlı olduğu merkezi bir liste (Redis) vardır. Bir kişi kapıya geldiğinde fedai listeye bakar, sayacı 1 artırır. Eğer 5 hakkını doldurduysa 'Dur bakalım, 1 dakika sokakta bekle!' der (HTTP 429). Lua Script ise fedainin listeye bakıp sayıyı artırma işini göz açıp kapayıncaya kadar tek bir saniyede (Atomik olarak) yapmasıdır; böylece iki kişi aynı anda kapıya yüklense bile fedaiyi kandıramaz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Picture a VIP nightclub bouncer guarding the velvet rope (Rate Limiter). House rule: 'No patron can enter more than 5 times per minute'. The bouncer holds a radio linked to the central clipboard (Redis). When a patron approaches, the bouncer checks the tally, increments the counter, and if the count exceeds 5, blocks entry with 'Wait 60 seconds on the curb!' (HTTP 429). The Redis Lua script ensures the bouncer checks and increments the clipboard atomically in a single nanosecond, preventing two patrons from rushing the rope simultaneously!]
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
      MAANG Seviyesi Dağıtık Hız Sınırlayıcı Mimarisi: 1) Yarış Durumu (Race Condition) Çözümü: Eğer uygulama Redis'ten `GET` yapıp kodda artırıp `SET` yaparsa, eşzamanlı iki istek aynı değeri okur ve limit aşılır. Çözüm: Redis Lua Scripting. Lua betikleri Redis motorunda tek iş parçacığında atomik olarak çalışır; sıfır kilit maliyetiyle `GET + INCR + EXPIRE` tek adımda biter. 2) Çok Bölgeli (Multi-Region) Senkronizasyon: Kullanıcı hem ABD hem Avrupa bölgesinden istek atıyorsa ne olur? Çözüm: A) Merkezi Redis (Ağ gecikmesi ekler). B) Yerel Redis + Asenkron Sync (CRDT / Eventual Consistency): Her bölgeye kotanın bir kısmı tahsis edilir (Local Quota Allocation) veya asenkron eşleme yapılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Distributed Rate Limiter Architecture: 1) Atomic Race Condition Elimination: Executing a separate `GET`, incrementing in JVM memory, and writing back via `SET` introduces fatal concurrency race windows. Resolution: Redis Lua Scripting executes `GET`, conditional comparison, `INCR`, and `EXPIRE` atomically within the Redis single-threaded engine in a single network round-trip. 2) Multi-Region Synchronization: If a user fires requests simultaneously across US-East and EU-West, cross-datacenter synchronization is required. Architecture Options: A) Centralized primary Redis cluster (adds 100ms cross-Atlantic latency). B) Localized Quota Splitting: Partition a user's 100 req/min allowance into 50 for US and 50 for EU, synchronizing background replenishment asynchronously via batch consensus.]
    ]
  )
]

#java25_box[
```java
// Java 25: Redis Lua Script Tabanlı Rate Limiting Mantığı Simülasyonu
public class RedisLuaRateLimiter {
    public static final String LUA_SCRIPT = """
        local key = KEYS[1]
        local limit = tonumber(ARGV[1])
        local window = tonumber(ARGV[2])
        
        local current = redis.call('get', key)
        if current and tonumber(current) >= limit then
            return 0 -- İzin Verilmedi (HTTP 429)
        else
            redis.call('incr', key)
            if not current then
                redis.call('expire', key, window)
            end
            return 1 -- İzin Verildi (HTTP 200)
        end
        """;

    public record RateLimitResult(boolean allowed, int remainingLimit, int retryAfterSeconds) {}
}

void main() {
    IO.println("Redis Lua Script Hazırlandı (Atomik GET + INCR + EXPIRE)");
    IO.println("Script Boyutu: " + RedisLuaRateLimiter.LUA_SCRIPT.trim().length() + " karakter");
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
      Mülakatta rate limiting için istemci IP adresini tek başına anahtar (Key) olarak seçmeyin! Aynı kurumsal ofisteki veya üniversitedeki 10.000 kişi aynı NAT Gateway IP'sini paylaşabilir; tek bir kullanıcının kotası dolunca tüm şirket bloklanır. Anahtar: `UserId` (Giriş yapmışsa) veya `UserId + IP` olmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never rely solely on client IP for rate limiting! Behind enterprise NAT proxies or university campuses, 10,000 distinct employees share a single public IP. Key by authenticated `UserId` or a combination of `DeviceFingerprint + IP`.]
    ]
  )
]

#takeaways_box((
    ("Redis Lua Scripting yarış durumlarını (Race Conditions) sıfır kilit maliyetiyle çözer.", "Redis Lua scripts execute check-and-increment operations atomically without distributed locks."),
    ("Kullanıcı deneyimi için HTTP 429 yanıtı ile birlikte 'Retry-After' başlığı dönülmelidir.", "Always accompany HTTP 429 responses with accurate Retry-After and X-RateLimit headers."),
    ("Çok bölgeli sistemlerde yerel kota tahsisi (Local Quota Splitting) ağ gecikmesini engeller.", "Local quota partitioning eliminates cross-datacenter WAN latency on edge rate checks."),
))
