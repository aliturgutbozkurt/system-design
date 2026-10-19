#import "/template.typ": *

#show: doc => setup_book(title: "Ders 40: Web Gezgini (Web Crawler) Tasarımı: URL Frontier, robots.txt ve Duplication", doc)

#lesson_header(
  40,
  "Web Gezgini (Web Crawler) Tasarımı: URL Frontier, robots.txt ve Duplication",
  "Designing a Web Crawler: URL Frontier, Politeness & Deduplication",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ GOOGLE TİPİ DAĞITIK WEB CRAWLER MİMARİSİ ]

   ┌─────────────────────────────────────────────────────────────┐
   │ URL FRONTIER (Öncelik ve Nezaket Kuyrukları - Politeness)   │
   │ Host Kuyrukları: [cnn.com] [wikipedia.org] [github.com]     │
   │ (Aynı sunucuyu saniyede 1 kereden fazla bombalama - Delay!) │
   └──────────────────────────────┬──────────────────────────────┘
                                  │
                                  ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ FETCH WORKERS (Virtual Threads ile Milyonlarca HTML İndir)  │
   └──────────────┬───────────────────────────────┬──────────────┘
                  │                               │
                  ▼                               ▼
   ┌─────────────────────────────┐ ┌─────────────────────────────┐
   │ CONTENT DEDUP (SimHash)     │ │ LINK EXTRACTOR (Yeni URL'ler│
   │ Daha önce indirildi mi?     │ │ çıkar ve URL Frontier'a at) │
   └─────────────────────────────┘ └─────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir kütüphanedeki tüm kitapları tek tek okuyup fihrist çıkaran çalışkan bir robot düşünün (Web Gezgini / Googlebot). Robot bir sayfa okur, sayfanın altındaki dipnotlarda başka kitapların referansını görür (Link Extraction). O yeni kitapları 'Okunacaklar Listesi'ne (URL Frontier) ekler. Ancak robot çok terbiyelidir (Politeness): Aynı yazarın odasına saniyede 100 kez girip kapıyı çalmaz; her yazarın arasına 2 saniye bekleme süresi koyar. Ayrıca daha önce okuduğu bir kitabı tekrar okumamak için hafızasındaki parmak izlerini (Deduplication) kontrol eder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine an automated librarian cataloging every book ever printed (Googlebot). It opens a book, reads the citations at the bottom (Link Extraction), and writes those new book titles onto a massive 'To-Read Clipboard' (URL Frontier). The librarian is strictly disciplined and polite (Politeness): it never pesters the same author 100 times per second, inserting a courteous 1-second delay between visits. It also checks a fingerprint catalog (Deduplication) so it never rereads identical duplicate books!]
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
      MAANG Web Crawler Mimarisi: 1) URL Frontier: İndirilecek URL'leri tutan kalıcı kuyruk sistemi. İki temel gereksinim: A) Önceliklendirme (Priority): Kaliteli ve popüler sayfalar önce taranır (PageRank tabanlı). B) Nezaket (Politeness): Aynı hedef alan adına (Host/Domain) giden isteklerin arasına gecikme (ör. 1000ms) konur; hedef sunucu DDoS saldırısına uğramaz. 2) DNS Önbellekleme: Milyonlarca istekte DNS sorguları darboğaz olmasın diye yerel DNS Cache tutulur. 3) İçerik Tekilleştirme (Content Deduplication): İnternetteki içeriğin %30'u mükerrerdir. HTML içeriğinin SimHash veya MinHash parmak izi alınarak Hamming Mesafesi (Hamming Distance) ile benzerlik kontrol edilir. 4) robots.txt: Taranmadan önce sitenin `robots.txt` kuralları okunur ve önbelleğe alınır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Architecture of a Distributed Web Crawler (Googlebot scale): 1) The URL Frontier: Governs URL scheduling via a dual-tiered queueing engine: A) Priority Queues order pages by freshness and PageRank. B) Politeness Queues group URLs by domain hostname, ensuring worker threads enforce delay intervals (e.g., 500ms) to avoid crashing target web hosts. 2) Dedicated Local DNS Caching: DNS lookups represent 30%+ of network latency; crawlers maintain in-memory high-throughput DNS caches. 3) Near-Duplicate Content Elimination: Over 30% of web pages are identical mirrors. Crawlers compute cryptographic 64-bit `SimHash` or `MinHash` locality-sensitive signatures, comparing Hamming Distance to discard duplicates before indexing. 4) robots.txt Compliance: Robots Exclusion Protocol files are fetched and cached in memory prior to scraping target paths.]
    ]
  )
]

#java25_box[
```java
// Java 25: SimHash Benzerlik ve Tekilleştirme (Deduplication) Algoritması
import java.math.BigInteger;

public class SimHashDeduplicator {
    public static long computeSimHash(String text) {
        int[] v = new int[64];
        String[] words = text.toLowerCase().split("\\s+");
        for (String word : words) {
            long hash = word.hashCode(); // Basit hash simülasyonu
            for (int i = 0; i < 64; i++) {
                if (((hash >> i) & 1L) == 1L) v[i]++;
                else v[i]--;
            }
        }
        long simHash = 0L;
        for (int i = 0; i < 64; i++) {
            if (v[i] > 0) simHash |= (1L << i);
        }
        return simHash;
    }

    // İki parmak izi arasındaki Hamming Mesafesi (Farklı bit sayısı)
    public static int hammingDistance(long h1, long h2) {
        return Long.bitCount(h1 ^ h2);
    }
}

void main() {
    String doc1 = "Java 25 and Spring Boot system design interview guide";
    String doc2 = "Java 25 and Spring Boot system design interview tutorial"; // Çok benzer!

    long hash1 = SimHashDeduplicator.computeSimHash(doc1);
    long hash2 = SimHashDeduplicator.computeSimHash(doc2);

    int distance = SimHashDeduplicator.hammingDistance(hash1, hash2);
    IO.println("Hamming Mesafesi: " + distance + " bit (Mesafe <= 3 ise MÜKERRER KABUL EDİLİR!)");
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
      Mülakatta 'BFS (Breadth-First Search) ile tararım' deyip geçmeyin! Saf BFS yaparsanız tek bir sitedeki 100.000 linki sırayla indirip o web sitesini çökertebilirsiniz (İhlal: Impolite). Nezaket (Politeness) kuyrukları ile farklı hostların dönüşümlü taranması zorunludur.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never propose naive Breadth-First Search (BFS) for web crawling. A pure BFS traversal hammers a single domain with thousands of concurrent connections, effectively staging a DDoS attack. Explicitly design Politeness queues.]
    ]
  )
]

#takeaways_box((
    ("URL Frontier, önceliklendirme ve nezaket (politeness) dengesini kuran omurgadır.", "The URL Frontier enforces both crawl prioritization and domain politeness constraints."),
    ("SimHash ve MinHash algoritmaları milyarlarca web sayfasındaki benzerlikleri saniyede eler.", "SimHash algorithms detect near-duplicate pages in constant time using Hamming distance."),
    ("Yerel DNS önbellekleme, web tarama hızını %30 artıran en kritik optimizasyondur.", "Dedicated in-memory DNS caching eliminates substantial latency bottlenecks during massive crawls."),
))
