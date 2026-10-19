#import "/template.typ": *

#show: doc => setup_book(title: "Ders 13: Önbellek Seviyeleri ve Donanım Piramidi (Her Mühendisin Bilmesi Gereken Sayılar)", doc)

#lesson_header(
  13,
  "Önbellek Seviyeleri ve Donanım Piramidi (Her Mühendisin Bilmesi Gereken Sayılar)",
  "Memory Hierarchy & Latency Numbers Every Engineer Must Know",
  "Önbellekleme Mimarisi ve CDN Stratejileri",
  "Distributed Caching Architectures & CDN Strategies"
)

#diagram_box[
```text
   [ DONANIM GECİKME PİRAMİDİ (JEFF DEAN'İN EFSANE SAYILARI) ]
           ▲
          / \     L1 Cache Referansı : ~1 nanosaniye (ns) [Göz kırpması]
         /   \    L2 Cache Referansı : ~4 ns
        / L3  \   Mutext Kilit/Kilit Aç: ~20 ns
       /  RAM  \  Ana Bellek (RAM)   : ~100 ns (100 kat daha yavaş!)
      /   NVMe  \ NVMe SSD Okuma     : ~10-100 mikrosaniye (µs)
     /    HDD    \HDD Disk Arama (Seek): ~10 milisaniye (ms) (100,000 kat yavaş!)
    /  İnternet   \Kıtalararası Ağ RTT: ~150 milisaniye (ms) [150,000,000 ns!]
   ───────────────
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Donanım hızlarını insan boyutuna uyarlayalım: L1 önbellekten veri okumak, masanızın üzerindeki kağıda bakmak gibidir (1 saniye sürer). RAM'den okumak, odadan çıkıp alt kattaki arşiv odasına yürümektir (1.5 dakika sürer). NVMe SSD'den okumak, komşu şehre arabayla gidip evrak almaktır (1.5 gün sürer). Dönen mekanik hard diskten (HDD) okumak, 3 ay süren bir dünya turuna çıkmaktır! İnternet üzerinden başka bir ülkeden veri çekmek ise Mars'a gidip gelmek gibidir (5 yıl sürer)! İşte önbellek, veriyi Mars'tan veya arşivden alıp masanızın üzerine koyma sanatıdır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Scaling computer latencies to human time: An L1 CPU cache reference is glancing at a sticky note on your desk (1 second). Fetching from RAM is walking downstairs to the building archives (90 seconds). Reading from an NVMe SSD is driving to a neighboring city (1.5 days). Reading from a spinning magnetic HDD is boarding a sailboat for a 3-month trans-Atlantic voyage! Fetching from a cross-continental remote API is a 5-year round trip to Mars! Caching is the supreme discipline of keeping hot data glued directly to your desk!]
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
      Jeff Dean'in ünlü 'Numbers Every Programmer Should Know' tablosu sistem tasarımının fiziksel zeminidir: L1 Cache: 0.5-1 ns, L2: 3-4 ns, RAM: 100 ns, SSD rastgele okuma: 16-100 µs, Veri merkezi içi RTT: 500 µs, HDD arama: 10 ms, Kaliforniya-Hollanda RTT: 150 ms. Bir veritabanı sorgusu disk ve ağ IO içerdiğinde milisaniyeler sürerken; RAM'deki bir Redis önbelleği mikrosaniyeler mertebesindedir (1.000 kat daha hızlı). Mülakatta veritabanı üzerindeki okuma yükünü %90 azaltmanın tek yolu bu piramidi doğru katmanlamaktır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Jeff Dean's latency benchmarks dictate distributed system sizing: L1: 1ns, L2: 4ns, RAM: 100ns, NVMe SSD read: 20µs, Datacenter RTT: 0.5ms, Mechanical disk seek: 10ms, Trans-Atlantic RTT: 150ms. Disk operations are orders of magnitude slower than DRAM access. Placing an in-memory Redis or Caffeine layer in front of relational databases reduces latency percentiles from 15ms down to 500µs while absorbing 95% of read pressure.]
    ]
  )
]

#java25_box[
```java
// Java 25: Donanım Gecikme Skalasını İnsan Zamanına Çeviren Model
public record LatencyScale(String operation, long nanos) {
    // 1 nanosaniyeyi 1 saniye kabul ederek insan ölçeğine çevir
    public String toHumanScale() {
        long seconds = nanos;
        if (seconds < 60) return seconds + " saniye";
        long minutes = seconds / 60;
        if (minutes < 60) return minutes + " dakika";
        long hours = minutes / 60;
        if (hours < 24) return hours + " saat";
        long days = hours / 24;
        if (days < 365) return days + " gün";
        return (days / 365) + " yıl";
    }
}

void main() {
    var l1 = new LatencyScale("L1 Cache", 1L);
    var ram = new LatencyScale("RAM Bellek", 100L);
    var ssd = new LatencyScale("NVMe SSD", 100_000L);
    var net = new LatencyScale("Trans-Atlantik Ağ", 150_000_000L);

    IO.println(l1.operation() + " -> " + l1.toHumanScale());
    IO.println(ram.operation() + " -> " + ram.toHumanScale());
    IO.println(ssd.operation() + " -> " + ssd.toHumanScale());
    IO.println(net.operation() + " -> " + net.toHumanScale());
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
      Mülakatta 'RAM ucuz, her şeyi sonsuza kadar Redis'te saklarım' demeyin! RAM, SSD'ye göre gigabayt başına yaklaşık 5-10 kat daha pahalıdır. Ön bellek sadece 'Sıcak Veri' (Hot Working Set) içindir; soğuk veriler daima disk/nesne depolamada tutulmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never declare 'RAM is cheap, I'll cache the entire 100TB database in Redis'. DRAM is 5x to 10x more expensive per gigabyte than NVMe. Caches are exclusively reserved for the 20% hot active working set.]
    ]
  )
]

#takeaways_box((
    ("RAM diskten 1.000 kat, ağ gecikmesinden 1.000.000 kat daha hızlıdır.", "DRAM is 1,000x faster than NVMe disks and 1,000,000x faster than cross-regional networks."),
    ("Sistem performansının en büyük düşmanı disk I/O ve ağ RTT gecikmesidir.", "The primary latency bottlenecks in web services are disk IO seeks and network RTT."),
    ("Önbellek, sıcak veriyi donanım piramidinin en tepesine yaklaştırma stratejisidir.", "Caching bridges physical latency penalties by lifting hot data to the top of the pyramid."),
))
