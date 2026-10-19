#import "/template.typ": *

#show: doc => setup_book(title: "Ders 6: Arka Plan Tahminleri (Back-of-the-Envelope Estimation): QPS, RAM ve Disk", doc)

#lesson_header(
  6,
  "Arka Plan Tahminleri (Back-of-the-Envelope Estimation): QPS, RAM ve Disk",
  "Back-of-the-Envelope Capacity Estimations (QPS, RAM, Storage)",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ MAANG KAPASİTE TAHMİNİ MATRİSİ (CHEAT SHEET) ]
  ┌────────────────────────┬─────────────────────────────────────────────┐
  │ 1 Gün = 86,400 Saniye  │ Kolay hesap için ~100,000 (10^5) saniye al! │
  │ 1 Milyon İstek / Gün   │ ~12 QPS                                     │
  │ 100 Milyon İstek / Gün │ ~1,200 QPS (Zirve: ~2,400 QPS)              │
  │ 1 Milyar İstek / Gün   │ ~12,000 QPS                                 │
  ├────────────────────────┼─────────────────────────────────────────────┤
  │ VERİ BOYUTLARI         │ 1 Char = 1 Byte | UUID = 16-36 B | Long = 8B│
  │ 100M tweet x 200 Byte  │ 20 GB / gün -> 5 Yılda: ~36 TB depolama     │
  │ %20 Önbellek Kuralı    │ Günlük okuma verisinin %20'si RAM'de tutulur│
  └────────────────────────┴─────────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir düğün organize ettiğinizi düşünün. Kaç gram et, kaç bardak su almanız gerektiğini hesaplamazsanız ya düğünün ortasında yemek biter rezil olursunuz ya da tonlarca et çürür paranız batar! Mülakatta da 'Twitter tasarlıyorum' dediğinizde mülakatçı kaç sunucuya, kaç terabayt diske ve ne kadar RAM'e ihtiyacınız olduğunu bilmek ister. Kimse sizden kuruşu kuruşuna kesin matematik beklemez; kabaca peçete arkasında yapılan (Back-of-the-envelope) mantıklı mühendislik tahminleri bekler!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Planning a wedding without estimating food means either guests starve midway through and riot, or you overbuy tons of meat that rots and bankrupts you! In a MAANG interview, if you say 'I will store all messages in memory', the interviewer will ask: 'How many gigabytes is that?' Nobody expects 5-decimal calculus; they expect rapid, disciplined back-of-the-envelope napkin math to sanity-check architectural feasibility!]
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
      MAANG mülakatlarında kapasite hesaplama matematiği: 1) Zaman Sabiti: 1 gün = 86,400 saniye ≈ 10^5 sn. 2) QPS Hesabı: 100M günlük istek / 100,000 sn ≈ 1,000 QPS (Zirve yük için 2x çarpanı alınır: 2,000 QPS). 3) Depolama Hesabı: Her kayıt 500 Byte ise, günlük veri = 100M x 500B = 50 GB/gün. 5 yıllık depolama = 50 GB x 365 x 5 ≈ 91 TB (3 kopya replikasyon ile ~270 TB). 4) Önbellek RAM Hesabı (Pareto 80/20 Kuralı): İsteklerin %80'i verinin %20'sinden gelir. Günlük 50 GB verinin %20'si = 10 GB RAM önbellek yeterlidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Back-of-the-envelope capacity arithmetic: 1) Time approximation: 1 day = 86,400s ≈ 10^5s. 2) QPS: 100M requests/day ÷ 10^5s ≈ 1,000 QPS average (multiply by 2-3x for peak traffic = 2,500 QPS). 3) Storage: If an entity payload is 500 Bytes, 100M items/day = 50 GB/day. 5-year retention: 50 GB × 365 × 5 ≈ 91.25 TB (with 3x replication factor = 273 TB). 4) Memory Sizing (Pareto 80/20 Rule): 80% of read traffic targets 20% of data. Cache 20% of daily read volume: 50 GB × 0.20 = 10 GB Redis memory footprint.]
    ]
  )
]

#java25_box[
```java
// Java 25: Peçete Arkası Kapasite Tahmin Motoru (Capacity Estimator)
public record CapacityEstimator(long dailyRequests, int payloadBytes) {
    public long averageQps() {
        return dailyRequests / 86_400;
    }

    public long peakQps() {
        return averageQps() * 2;
    }

    public double dailyStorageGigabytes() {
        return (dailyRequests * (double) payloadBytes) / (1024 * 1024 * 1024);
    }

    public double fiveYearStorageTerabytes(int replicationFactor) {
        return (dailyStorageGigabytes() * 365 * 5 * replicationFactor) / 1024;
    }

    public double cacheMemoryGigabytes(double paretoRatio) {
        return dailyStorageGigabytes() * paretoRatio;
    }
}

void main() {
    var estimator = new CapacityEstimator(100_000_000L, 500);
    IO.println("Ortalama QPS:    " + estimator.averageQps());
    IO.println("Zirve (Peak) QPS: " + estimator.peakQps());
    IO.println("Günlük Depolama: " + String.format("%.2f GB", estimator.dailyStorageGigabytes()));
    IO.println("5 Yıllık (3x Rep):" + String.format("%.2f TB", estimator.fiveYearStorageTerabytes(3)));
    IO.println("RAM Önbellek:    " + String.format("%.2f GB", estimator.cacheMemoryGigabytes(0.20)));
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
      Hesaplama yaparken 86,400 ile tam bölmeye çalışıp vakit kaybetmeyin. Mülakatçıya 'Hesabı kolaylaştırmak için 1 günü 100.000 saniye kabul ediyorum' deyin; bu pratik mühendislik refleksiniz için artı puan kazandırır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Do not waste precious interview minutes dividing by 86,400 by hand. Explicitly tell the interviewer: 'I will approximate 86,400 as 100,000 seconds for rough sizing'; they will appreciate your pragmatism.]
    ]
  )
]

#takeaways_box((
    ("1 gün ≈ 100,000 saniye kuralı QPS hesaplarını saniyeler içinde çözmenizi sağlar.", "Use 1 day ≈ 10^5 seconds to compute baseline QPS within 5 seconds."),
    ("Zirve (Peak) QPS her zaman ortalama QPS'in 2 ila 3 katı olarak kabul edilir.", "Dimension service throughput for Peak QPS (typically 2x to 3x average QPS)."),
    ("Pareto 80/20 kuralı sayesinde günlük verinin %20'sini önbelleğe almak yeterlidir.", "The Pareto 80/20 heuristic sizes distributed cache memory at 20% of daily active working set."),
))
