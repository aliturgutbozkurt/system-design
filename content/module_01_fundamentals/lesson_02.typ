#import "/template.typ": *

#show: doc => setup_book(title: "Ders 2: Dikey vs Yatay Ölçekleme (Scale-Up vs Scale-Out) & Donanım Sınırları", doc)

#lesson_header(
  2,
  "Dikey vs Yatay Ölçekleme (Scale-Up vs Scale-Out) & Donanım Sınırları",
  "Vertical vs Horizontal Scaling & Hardware Bottlenecks",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ DİKEY ÖLÇEKLEME / SCALE-UP ]           [ YATAY ÖLÇEKLEME / SCALE-OUT ]
          ┌─────────────┐                    ┌────────┐ ┌────────┐ ┌────────┐
          │   DEVASA    │                    │ Node 1 │ │ Node 2 │ │ Node 3 │
          │   SUNUCU    │                    └───┬────┘ └───┬────┘ └───┬────┘
          │ (128 Core,  │                        │          │          │
          │  2 TB RAM)  │                        ▼          ▼          ▼
          └─────────────┘                 ┌─────────────────────────────────┐
    • Donanım tavanı vardır!              │      LOAD BALANCER / KÜME       │
    • Tek Hata Noktası (SPOF)!            └─────────────────────────────────┘
    • Maliyeti katlanarak artar.            • Sınırsız yatay büyüme imkanı
                                            • Hata toleransı (Biri ölürse diğeri yaşar)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Diyelim ki bir pizzacınız var ve siparişlere yetişemiyorsunuz. Dikey ölçekleme (Scale-Up), dükkana dünyanın en kaslı, 8 kollu süper aşçısını transfer etmektir. Bir yere kadar harikadır ama o aşçı da yorulur, hasta olursa dükkan kapanır ve maaşı bir servettir! Yatay ölçekleme (Scale-Out) ise mutfağa standart 10 tane normal aşçı koyup siparişleri aralarında paylaştırmaktır. Aşçılardan biri bayılsa bile diğer 9 aşçı pizza yapmaya devam eder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine a bustling pizzeria running out of oven capacity. Vertical scaling (Scale-Up) is hiring an expensive superhero chef with 8 arms. It works initially, but even superhuman chefs have physical limits, and if they catch the flu, your pizzeria goes bankrupt! Horizontal scaling (Scale-Out) is hiring 10 ordinary cooks and distributing orders across them. If cook #3 twists an ankle, the other 9 keep cooking seamlessly!]
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
      Dikey ölçekleme (Scale-Up), sunucunun CPU, RAM veya SSD kapasitesini artırmaktır. Avantajı: Kod değişikliği gerektirmez, dağıtık sistem karmaşıklığı yoktur. Dezavantajı: Donanım sınırları (fizik kuralları), üstel maliyet artışı ve Tek Hata Noktası (SPOF). Yatay ölçekleme (Scale-Out), sisteme daha fazla ucuz/standart emtia makine (commodity hardware) eklemektir. Durumsuz (stateless) servisler için kusursuzdur; ancak veritabanlarında veri tutarlılığı, replikasyon ve ağ gecikmesi karmaşıklığı getirir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Vertical scaling (Scale-Up) augments an existing node with more cores, RAM, and NVMe drives. Pros: Zero distributed networking overhead and seamless operational simplicity. Cons: Hard hardware ceilings, exponential cloud cost curves, and single point of failure (SPOF). Horizontal scaling (Scale-Out) pools clusters of commodity nodes behind load balancers. Trivial for stateless application tiers, but introduces distributed consensus, sharding, and network partition complexities on stateful databases.]
    ]
  )
]

#java25_box[
```java
// Java 25: Virtual Threads (Project Loom) ile Yatay İşçi Havuzu Simülasyonu
import java.util.concurrent.*;

public class HorizontalWorkerPool {
    public static void main(String[] args) throws InterruptedException {
        // Java 25: Milyonlarca hafif sanal iş parçacığı (Virtual Threads)
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 1; i <= 5; i++) {
                final int workerId = i;
                executor.submit(() -> {
                    IO.println("İşçi Düğüm #" + workerId + " görev yürütüyor: " 
                        + Thread.currentThread());
                });
            }
        } // Executor otomatik kapanır ve tüm görevlerin bitmesini bekler
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
      Mülakatta 'Veritabanını hemen 100 parçaya bölerim (Sharding)' demeyin! Önce Read-Replica, Cache (Redis) ve Dikey Büyütme alternatiflerini tüketip, sharding'in getirdiği iki fazlı onay (2PC) ve cross-partition join zorluklarını bildiğinizi vurgulayın.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Do not scream 'Database Sharding!' at minute 10. Sharding introduces massive operational overhead like cross-partition joins and re-balancing. Always exhaust Read Replicas, Caching, and Vertical headroom first.]
    ]
  )
]

#takeaways_box((
    ("Uygulama katmanı (Stateless) daima yatay ölçeklenmelidir.", "Stateless application tiers should always be scaled horizontally behind load balancers."),
    ("Veritabanı katmanında dikey ölçekleme sınırına ulaşılınca Okuma Replikaları ve ardından Sharding devreye girer.", "Scale databases via Read Replicas and caching before resorting to horizontal sharding."),
    ("Yatay ölçekleme hata izolasyonu (fault isolation) sağlayarak sistemi çökmelere karşı korur.", "Horizontal scaling unlocks true fault tolerance by eliminating single points of failure."),
))
