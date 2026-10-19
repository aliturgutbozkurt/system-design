#import "/template.typ": *

#show: doc => setup_book(title: "Ders 38: Pastebin / Metin Paylaşım Servisi Tasarımı: TTL, S3 Blob Depolama ve Temizlik", doc)

#lesson_header(
  38,
  "Pastebin / Metin Paylaşım Servisi Tasarımı: TTL, S3 Blob Depolama ve Temizlik",
  "Designing Pastebin: Object Storage (S3), TTL & Janitor Service",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ PASTEBIN METİN PAYLAŞIM MİMARİSİ ]

   İstemci ──1. POST /api/pastes (100 KB Kod Metni)──▶ [ API GATEWAY ]
                                                              │
                                                              ▼
                                                   [ Pastebin Servisi ]
                                                              │
                 ┌────────────────────────────────────────────┴───────────────────────────┐
                 │ 1. Metadata (Küçük)                        │ 2. Asıl İçerik (Büyük)    │
                 ▼                                            ▼
   ┌───────────────────────────────────────────┐  ┌───────────────────────────────────────┐
   │ METADATA VERİTABANI (PostgreSQL / NoSQL)  │  │ NESNE DEPOLAMA (OBJECT STORE - S3)    │
   │ paste_id (PK), user_id, expires_at, s3_key│  │ S3 Key: "pastes/2026/10/a8B9z1.txt"   │
   └───────────────────────────────────────────┘  └───────────────────────────────────────┘
                                ▲
                                │ Süresi Dolanları Sil (TTL)
   ┌────────────────────────────┴──────────────┐
   │ JANITOR WORKER (Periyodik Temizlik Motoru)│
   └───────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Büyük bir kütüphanede emanet dolapları olduğunu düşünün: Dolabın kapağında sadece emanet fişi ve son teslim tarihi yazar (Metadata), dolabın içinde ise koca bir bavul eşya durur (Büyük Metin / S3). Siz fiş numarasını verirsiniz, görevli kapağa bakar, bavulunuzu çıkarıp verir. Eğer dolabın süresi dolmuşsa (TTL), gece gelen temizlik görevlisi (Janitor Service) bavulu boşaltıp çöp fırınına atar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Think of a luggage locker terminal at a central train station: The digital locker display shows only the locker ticket ID and expiration date (Metadata), while the spacious locker compartment holds a massive 50-pound travel suitcase (Text Payload / S3). You scan your ticket; the door opens. If a traveler abandons their locker beyond the paid rental window (TTL), a nightly maintenance crew (Janitor Service) empties the locker to free up capacity!]
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
      Pastebin ve TinyURL arasındaki en kritik fark: TinyURL'de veri birkaç yüz bayt iken, Pastebin'de her içerik 10 KB - 10 MB arasında devasa metinler içerebilir. 1) Veri Ayrımı (Storage Segregation): Büyük metin gövdesi veritabanında (RDBMS) ASLA `TEXT/BLOB` olarak tutulmaz! Metin doğrudan ucuz ve sınırsız ölçeklenen Nesne Depolamada (AWS S3, MinIO) saklanır. Veritabanında yalnızca metadata tutulur (`paste_id`, `s3_key`, `created_at`, `expires_at`). 2) Süre Aşımı ve Temizlik (TTL & Janitor): Süresi dolan kayıtlar veritabanından anında silinmez (DB kilitlenmesini önlemek için). İstemci okurken `expires_at \< now()` ise '404 Bulunamadı' dönülür. Arka planda çalışan bir 'Janitor Service' (gece batch worker) süresi dolan kayıtları ve S3 dosyalarını toplu olarak temizler.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The critical divergence between TinyURL and Pastebin is payload magnitude: TinyURL stores 200-byte strings, while Pastebin accepts 100KB to 10MB text blobs. Architectural Tenet: Never store unbounded text payloads directly inside relational database tables! Store raw payloads inside cost-effective Object Stores (AWS S3 / Google Cloud Storage), persisting only compact metadata inside PostgreSQL or Cassandra (`paste_id`, `author_id`, `s3_uri`, `expiration_timestamp`). TTL & Lazy Cleanup: Avoid running active delete queries on hot tables. On read paths, check `expires_at \< NOW()` and return 404. Offload actual physical deletions to an asynchronous Janitor Worker that batch-purges expired S3 blobs and DB rows during off-peak hours.]
    ]
  )
]

#java25_box[
```java
// Java 25: Pastebin Metadata & Süre Kontrol Modeli
import java.time.Instant;

public record PasteMetadata(String pasteId, String s3Uri, Instant expiresAt) {
    public boolean isExpired() {
        return Instant.now().isAfter(expiresAt);
    }
}

void main() {
    var activePaste = new PasteMetadata("pst_101", "s3://pastes/pst_101.txt", Instant.now().plusSeconds(3600));
    var expiredPaste = new PasteMetadata("pst_102", "s3://pastes/pst_102.txt", Instant.now().minusSeconds(10));

    IO.println("Paste 101 Süresi Doldu mu? " + activePaste.isExpired()); // false
    IO.println("Paste 102 Süresi Doldu mu? " + expiredPaste.isExpired()); // true -> HTTP 404!
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
      Mülakatta '10 MB'lık kod parçalarını PostgreSQL tablosunda VARCHAR sütununda saklarım' derseniz elenirsiniz! Veritabanına büyük metin yazmak disk IO ve bellek önbelleğini şişirir; metin daima S3/Blob depolamada saklanmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never propose storing multi-megabyte paste payloads inside an RDBMS table column. This severely fragments database pages and destroys buffer pool caching. Payloads belong in Object Storage (S3).]
    ]
  )
]

#takeaways_box((
    ("Büyük veri yükleri (payloads) Nesne Depolamada (S3), metadata ise veritabanında tutulur.", "Large payloads live in Object Storage (S3); metadata lives in relational/document DBs."),
    ("Süresi dolan içerikler için tembel kontrol (Lazy Evaluation) ve periyodik Janitor Worker kullanılır.", "Combine lazy read-time expiration checks with asynchronous background janitor purging."),
    ("Kullanıcıların paste aramaları için metadata veritabanında paste_id ve user_id indekslenir.", "Index author IDs and expiration timestamps to support high-performance user dashboard queries."),
))
