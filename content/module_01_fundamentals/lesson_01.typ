#import "/template.typ": *

#show: doc => setup_book(title: "Ders 1: 4 Adımlı MAANG Mülakat Çerçevesi (RADAR Metodu)", doc)

#lesson_header(
  1,
  "4 Adımlı MAANG Mülakat Çerçevesi (RADAR Metodu)",
  "The 4-Step MAANG Interview Blueprint (RADAR Method)",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 MAANG SYSTEM DESIGN INTERVIEW TIMELINE (45 MIN)             │
└─────────────────────────────────────────────────────────────────────────────┘
  [0-5 min]       [5-15 min]           [15-30 min]          [30-45 min]
 ┌──────────┐    ┌──────────────┐     ┌──────────────┐     ┌───────────────┐
 │ STEP 1   │───▶│ STEP 2       │────▶│ STEP 3       │────▶│ STEP 4        │
 │ Scope &  │    │ High-Level   │     │ Deep Dive    │     │ Bottlenecks   │
 │ Clarify  │    │ Architecture │     │ & Data Model │     │ & Resilience  │
 └──────────┘    └──────────────┘     └──────────────┘     └───────────────┘
  • Functional    • Client, LB        • DB Schema &        • Single Points
    & Non-Func.   • Core Services       Indexes              of Failure
  • DAU & QPS     • Cache & DB        • Read/Write APIs    • P99 Latency
  • Storage Est.  • Message Queue     • Trade-offs         • Auto-scaling
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir inşaat mühendisi mülakatında 'Bana bir bina yap' dediklerinde hemen elinize tuğla alıp harç karmaya başlamazsınız! 'Kaç kişilik bir bina? 2 katlı bir yazlık mı, yoksa 80 katlı rüzgara dayanıklı bir gökdelen mi?' diye sorarsınız. MAANG mülakatı da böyledir: Mülakatçı size bilerek muğlak bir soru sorar ('Twitter tasarla'). Hemen kod yazmaya başlarsanız elenirsiniz! Önce gereksinimleri netleştirir (Scope), ardından kaba taslağı çizer (High-Level), kritik parçaların röntgenini çeker (Deep Dive) ve sistemi zorlayıp darboğazları çözersiniz (Bottlenecks)!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[If a master architect is asked: 'Build me a structure', they don't immediately start mixing cement! They ask: 'Is this a 2-family wooden cabin or an 80-story earthquake-proof skyscraper?' MAANG interviews operate on the exact same premise: interviewers give intentionally vague prompts ('Design Twitter'). If you dive straight into drawing databases, you fail immediately. You must follow the 4 steps: clarify the scope, outline high-level blocks, deep-dive into bottlenecks, and harden failure domains!]
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
      45 dakikalık MAANG sistem tasarımı mülakatının altın zaman planı: 1) Kapsam & Gereksinimler (5 dk): Fonksiyonel (Tweet atma, akış okuma) ve Fonksiyonel Olmayan (100M DAU, P99 \< 200ms, 99.99% erişilebilirlik, read-heavy 100:1) hedefler. 2) Yüksek Seviye Mimari (10 dk): İstemci, DNS, CDN, LB, API Gateway, Mikroservisler ve Depolama blokları. 3) Derinlemesine Tasarım (15 dk): Veri şeması, NoSQL vs SQL seçimi, önbellek katmanı ve fan-out stratejisi. 4) İyileştirme & Darboğazlar (15 dk): SPOF (Single Point of Failure), partition stratejisi, rate limiter ve felaket kurtarma.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The rigorous 45-minute MAANG system design framework: 1) Scope & Clarification (5 min): Differentiate functional vs non-functional constraints (100M DAU, Read-to-Write ratio 100:1, P99 \< 200ms, 99.99% availability). 2) High-Level Architecture (10 min): Map clients, DNS, CDN, L4/L7 Load Balancers, Gateways, Stateless Services, Cache, and Persistence. 3) Core Deep Dive (15 min): Schema design, data models, sharding keys, and query paths. 4) Bottlenecks & Operational Resiliency (15 min): Mitigate Single Points of Failure (SPOFs), backpressure, and cross-datacenter failover.]
    ]
  )
]

#java25_box[
```java
// Java 25: Mülakat Metriklerini ve SLA Değerlerini Temsil Eden Record Modeli
public record SystemRequirement(
    String systemName,
    long dailyActiveUsers,
    int readWriteRatio,
    double targetAvailabilityPercentage,
    int targetP99LatencyMillis
) {
    public long calculateDailyReadQps() {
        long dailyWrites = dailyActiveUsers * 2; // Kullanıcı başı 2 yazma
        long dailyReads = dailyWrites * readWriteRatio;
        return dailyReads / 86_400; // Saniyelik ortalama QPS
    }

    public long calculatePeakQps() {
        return calculateDailyReadQps() * 2; // Zirve yük çarpanı: 2x
    }
}

// Java 25 Main metodu ile çalıştırma:
void main() {
    var twitterReq = new SystemRequirement("Twitter Feed", 200_000_000L, 100, 99.99, 150);
    IO.println("Ortalama Okuma QPS: " + twitterReq.calculateDailyReadQps());
    IO.println("Zirve (Peak) Okuma QPS: " + twitterReq.calculatePeakQps());
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
      En ölümcül mülakat hatası: Soru sorulur sorulmaz sessiz kalıp doğrudan çizim yapmaya başlamaktır. Mülakat bir monolog değil, gelecekteki iş arkadaşınızla yaptığınız mimari bir istişaredir (collaborative dialogue).
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The single most fatal mistake is jumping straight into drawing database boxes in absolute silence. A system design round is an interactive architectural collaboration, not an exam paper.]
    ]
  )
]

#takeaways_box((
    ("İlk 5 dakikayı mutlaka fonksiyonel ve non-fonksiyonel gereksinimleri netleştirmeye ayırın.", "Spend the initial 5 minutes strictly clarifying functional bounds and non-functional SLAs."),
    ("Tasarımı bir kerede mükemmel yapmaya çalışmayın; basitten başlayıp ölçekleyin.", "Start with an intuitive baseline architecture, then evolve it under simulated scale."),
    ("Her mimari kararın arkasında bir 'Trade-off' (ödünleşim) gerekçesi sunun.", "Always articulate the trade-offs and rationale behind every database or caching choice."),
))
