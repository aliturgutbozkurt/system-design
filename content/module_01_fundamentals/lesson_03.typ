#import "/template.typ": *

#show: doc => setup_book(title: "Ders 3: Gecikme (Latency), Verim (Throughput) ve Ağ Temelleri (P99 Yanılgısı)", doc)

#lesson_header(
  3,
  "Gecikme (Latency), Verim (Throughput) ve Ağ Temelleri (P99 Yanılgısı)",
  "Latency, Throughput & Tail Latency (The P99 Fallacy)",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ ORTALAMA GECİKME TUZAĞI (AVERAGE TRAP) vs PERCENTILE ]
      İstek Sayısı
          ▲
          │       Ortalama = 50ms (Harika görünüyor!)
          │         │
          │     ┌───┴───┐
          │    ┌┤       ├┐
          │   ┌┘│       │└┐           P99 = 2500ms (Kullanıcı isyanda!)
          │  ┌┘ │       │ └──────┐          │
          └──┴──┴───────┴────────┴──────────┴───────────▶ Yanıt Süresi (ms)
             50ms       100ms             2500ms (Kuyruk Gecikmesi / GC Pause)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir havaalanı pasaport kuyruğunu düşünün. 100 yolcudan 99'u pasaporttan 10 saniyede geçiyor; ancak 1 yolcu şüpheli valiz araması yüzünden 45 dakika bekliyor. Havaalanı müdürü 'Ortalama bekleme süremiz sadece 30 saniye!' derse bu istatistik gerçeği yansıtır mı? O 45 dakika bekleyen yolcu Twitter'da olay çıkarır! MAANG şirketleri ortalamaya (Average) asla inanmaz; P99'a (yani en şanssız %1'lik kullanıcının yaşadığı gecikmeye) bakar!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Consider an airport security checkpoint. 99 travelers breeze through in 10 seconds, but 1 unlucky passenger gets held for a 45-minute bag search. If the airport director claims: 'Our average wait time is only 35 seconds!', it masks a nightmare! That stalled passenger will rage on social media. MAANG engineers never track simple averages; they obsess over P99 and P99.9 (the tail latency suffered by the unluckiest 1% of users)!]
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
      Gecikme (Latency), bir isteğin istemciden çıkıp sunucuda işlenip geri dönene kadar geçen süredir (RTT + processing). Verim (Throughput / QPS), sistemin birim zamanda tamamladığı işlem sayısıdır. Ortalama gecikme (Mean), uzun kuyruk gecikmelerini (Tail Latency), JVM GC duraklamalarını (Stop-the-World) ve disk IO darboğazlarını gizler. Modern bir web sayfasında 100 alt mikroservis çağrısı yapılıyorsa, ortalama bir kullanıcının en az 1 kez P99 gecikmesine çarpma olasılığı: 1 - (0.99)^100 = %63.4'tür! Yani kullanıcıların üçte ikisi yavaşlığa maruz kalır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Latency is the elapsed duration for a round-trip request (network RTT + queueing + execution). Throughput (QPS/RPS) is system processing capacity per unit of time. The average (mean) latency is dangerously misleading because it masks tail latency spikes caused by garbage collection, lock contention, and TCP packet drops. If a web request aggregates calls across 100 microservices, the probability that a single end-user experiences a P99 tail latency is 1 - (0.99)^100 ≈ 63.4%! Tail latencies dominate user perception.]
    ]
  )
]

#java25_box[
```java
// Java 25: Percentile (P50, P90, P99) Hesaplayıcı Motoru
import java.util.*;

public class LatencyPercentileTracker {
    private final List<Long> latencies = new ArrayList<>();

    public synchronized void recordLatency(long durationMillis) {
        latencies.add(durationMillis);
    }

    public synchronized long getPercentile(double percentile) {
        if (latencies.isEmpty()) return 0;
        List<Long> sorted = new ArrayList<>(latencies);
        Collections.sort(sorted);
        int index = (int) Math.ceil((percentile / 100.0) * sorted.size()) - 1;
        return sorted.get(Math.max(0, index));
    }
}

void main() {
    var tracker = new LatencyPercentileTracker();
    // 99 hızlı istek (10-30ms), 1 adet felaket yavaş istek (2500ms)
    for (int i = 0; i < 99; i++) tracker.recordLatency(20);
    tracker.recordLatency(2500);

    IO.println("P50 (Medyan): " + tracker.getPercentile(50) + " ms");
    IO.println("P99 (Tail):   " + tracker.getPercentile(99) + " ms");
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
      Mülakatçınız 'Sistem yanıt süreleriniz nasıl?' dediğinde 'Ortalama 50ms' deyip geçerseniz Senior seviyesinin altında kalırsınız. 'P50 medyanımız 30ms, P99 kuyruk gecikmemiz ise 120ms altında garanti edilir' şeklinde yanıt verin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Reporting simple average latencies during system design flags you as a junior engineer. Always discuss percentiles: 'Our median P50 is 25ms, while our P99 tail latency is bounded below 150ms.']
    ]
  )
]

#takeaways_box((
    ("Ortalama gecikme (Mean), sistemdeki darboğazları ve memnuniyetsiz kullanıcıları gizler.", "Mean latency masks catastrophic tail latency anomalies and user dissatisfaction."),
    ("Yüzlerce mikroservisin olduğu mimarilerde P99 gecikmesi tüm sistemi domine eder.", "In fan-out microservice topologies, P99 tail latencies compound exponentially."),
    ("P99'u düşürmek için timeout sınırları, circuit breaker ve spekülatif yeniden denemeler kullanılır.", "Mitigate tail latencies using strict deadlines, speculative retries, and circuit breakers."),
))
