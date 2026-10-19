#import "/template.typ": *

#show: doc => setup_book(title: "Ders 37: URL Kısaltıcı Tasarımı (TinyURL / Bit.ly): Base62, Çarpışma Önleme ve 100M DAU", doc)

#lesson_header(
  37,
  "URL Kısaltıcı Tasarımı (TinyURL / Bit.ly): Base62, Çarpışma Önleme ve 100M DAU",
  "Designing a URL Shortener (TinyURL / Bit.ly): Base62 & Scale",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ TINYURL SİSTEM MİMARİSİ VE VERİ AKIŞI ]
   İstemci ──1. POST /api/shorten (Uzun URL)──▶ [ API GATEWAY ]
                                                        │
                                                        ▼
                                             [ URL Shortener Servisi ]
                                             (KGS: Key Gen Service)
                                                        │
                        ┌───────────────────────────────┴───────────────────────────────┐
                        │ Base62 Kodlama: ID -> "7bA9xK"                                │
                        ▼                                                               ▼
           ┌─────────────────────────┐                                     ┌─────────────────────────┐
           │ REDIS CACHE (Sıcak URL) │                                     │ NOSQL / SQL VERİTABANI  │
           │ Key: "7bA9xK"           │                                     │ short_hash (PK)         │
           │ Val: "https://long..."  │                                     │ original_url, created_at│
           └─────────────────────────┘                                     └─────────────────────────┘
   Yönlendirme Akışı: GET /7bA9xK ──▶ Redis'te varsa hemen HTTP 301 / 302 Yönlendirmesi!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kütüphanedeki 500 sayfalık kalın bir kitabın adını arkadaşınıza söylerken kitabın tüm içeriğini okumazsınız; ona 'A-12 nolu raftaki kitap' dersiniz (Kısa Kod). Arkadaşınız rafa gider ve koca kitabı bulur. TinyURL de budur: 200 karakterlik devasa bir internet adresini alır (`https://example.com/very/long/url...`), onu 7 karakterlik sevimli bir plakaya (`tinyurl.com/a8B9z1`) dönüştürür. Biri o plakayı tıkladığında sistem plakayı gerçek adrese yönlendirir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Instead of shouting the entire 500-page contents of an encyclopedia across a room, you hand your friend a tiny library call number: 'Shelf B-42' (Short Code). Your friend walks to shelf B-42 and retrieves the tome. TinyURL works identically: it takes an unruly 250-character URL and hashes it into a compact 7-character vanity token (`tiny.one/x9K2pQ`). When a browser accesses that token, the server returns an instant HTTP redirect to the long target destination!]
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
      MAANG Seviyesi TinyURL Tasarım Analizi: 1) Kapasite Hesabı: 100M yeni URL/gün. 10 yılda: 100M x 365 x 10 ≈ 365 Milyar URL. 2) Base62 Kodlama: [0-9, a-z, A-Z] = 62 karakter. 7 karakterlik bir kısa kod: 62^7 = 3.52 × 10^12 (3.5 Trilyon benzersiz kombinasyon sunar; 365 milyarı fazlasıyla karşılar). 3) Hash Çarpışması Önleme: MD5/SHA256 alıp ilk 7 karakteri kesmek çarpışma (Collision) riski taşır. En iyi mimari: 'Key Generation Service' (KGS) ile bağımsız bir servisin önceden benzersiz 7 karakterlik Base62 anahtarları üretip veritabanına koymasıdır. 4) HTTP 301 vs 302: 301 (Moved Permanently) tarayıcı tarafından önbelleğe alınır, sunucu yükünü düşürür ancak tıklama analitiğini (analytics) bozar. 302 (Found) geçicidir; her istek sunucudan geçer, tıklama sayımı kusursuz çalışır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG-Grade Architecture for TinyURL: 1) Capacity: 100M writes/day. 10-year horizon: 365 billion URLs. 2) Base62 Encoding: [0-9, a-z, A-Z] yields 62 alphanumeric permutations. A 7-character token provides 62^7 ≈ 3.52 trillion unique keys. 3) Collision Elimination: Hashing the original URL via SHA-256 and truncating introduces collision loops. Optimal approach: Key Generation Service (KGS) that generates sequential monotonic Snowflake IDs and encodes them to Base62, pre-loading tokens into memory. 4) HTTP 301 vs 302 Redirects: 301 (Moved Permanently) is cached by the client browser, reducing origin QPS while breaking real-time click telemetry. 302 (Found / Temporary Redirect) forces every click through the gateway, capturing user-agent, referer, and IP analytics.]
    ]
  )
]

#java25_box[
```java
// Java 25: 64-Bit Sayıyı Base62 Karakter Dizisine Dönüştürücü (URL Shortener Motoru)
public class Base62Encoder {
    private static final String BASE62_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

    public static String encode(long number) {
        if (number == 0) return "0";
        var sb = new StringBuilder();
        while (number > 0) {
            int remainder = (int) (number % 62);
            sb.append(BASE62_ALPHABET.charAt(remainder));
            number /= 62;
        }
        return sb.reverse().toString();
    }
}

void main() {
    long uniqueId = 12519284192L; // Snowflake veya DB Identity
    String shortCode = Base62Encoder.encode(uniqueId);
    IO.println("Benzersiz ID: " + uniqueId + " ──▶ Kısa Kod: " + shortCode);
    IO.println("Oluşan URL:   https://tiny.url/" + shortCode);
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
      Mülakatta 'MD5 hash'i alıp ilk 7 karakterini keserim' deyip geçmeyin! İki farklı URL aynı ilk 7 karaktere sahip olabilir (Çarpışma). Mülakatçıya Snowflake ID + Base62 dönüşümünü veya KGS (Key Generation Service) ön-üretim modelini sunduğunuzda doğrudan Staff seviyesine çıkarsınız.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Suggesting a naive SHA-256 truncation without addressing hash collisions is an immediate deduction. Propose a distributed Key Generation Service (KGS) or a monotonic Snowflake sequence mapped deterministically through Base62.]
    ]
  )
]

#takeaways_box((
    ("Base62 [0-9, a-z, A-Z] 7 karakterde 3.5 trilyon benzersiz kombinasyon üretir.", "Base62 with 7 characters yields 3.52 trillion collision-free combinations."),
    ("HTTP 302 yönlendirmesi tıklama analitiğini takip etmek için tercih edilir.", "HTTP 302 redirects preserve accurate click telemetry and analytics at the gateway."),
    ("Okuma/Yazma oranı 100:1 olduğu için Redis önbelleği okuma gecikmesini \<5ms seviyesine indirir.", "A 100:1 read-to-write ratio mandates an aggressive Redis cache for sub-5ms lookups."),
))
