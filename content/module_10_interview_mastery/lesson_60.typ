#import "/template.typ": *

#show: doc => setup_book(title: "Ders 60: Büyük Kurumsal Final: Staff+ Zihniyeti, Trade-Off Savunması ve Mülakat Altın Rehberi", doc)

#lesson_header(
  60,
  "Büyük Kurumsal Final: Staff+ Zihniyeti, Trade-Off Savunması ve Mülakat Altın Rehberi",
  "Grand Enterprise Finale: The Staff+ Mindset, Trade-Off Mastery & Golden Rubric",
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook"
)

#diagram_box[
```text
   [ MAANG STAFF+ SİSTEM TASARIMI BAŞARI MATRİSİ (THE GOLDEN RUBRIC) ]

                     ┌──────────────────────────────────────────────────┐
                     │ 1. KAPSAM VE NETLİK (Scope & Disambiguation)     │
                     │ Belirsizliği yönet, sınırları çiz, varsayım kur  │
                     └────────────────────────┬─────────────────────────┘
                                              │
                     ┌────────────────────────┴─────────────────────────┐
                     │ 2. SAĞLAM TEMELLER (Architectural Baseline)      │
                     │ Basit, durumsuz, ölçeklenebilir ve temiz çizim   │
                     └────────────────────────┬─────────────────────────┘
                                              │
                     ┌────────────────────────┴─────────────────────────┐
                     │ 3. DERİNLEMESİNE UZMANLIK (Deep Technical Mastery)│
                     │ CAP, LSM-Tree, Raft, Consistent Hash, Zero-Copy  │
                     └────────────────────────┬─────────────────────────┘
                                              │
                     ┌────────────────────────┴─────────────────────────┐
                     │ 4. TRADE-OFF SAVUNMASI (No Free Lunch Principle) │
                     │ "Her çözümün bir bedeli vardır; ben bunu seçtim!"│
                     └────────────────────────┬─────────────────────────┘
                                              │
                     ┌────────────────────────┴─────────────────────────┐
                     │ 5. OPERASYONEL GERÇEKÇİLİK (Day-2 Operations)    │
                     │ Gözlemlenebilirlik, FinOps, Güvenlik, DR         │
                     └──────────────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Tebrikler! 60 derslik muazzam bir yolculuğun zirvesine ulaştınız. Artık sistem tasarımına sadece 'kutular çizip aralarına oklar koyan' bir yazılımcı olarak bakmıyorsunuz; devasa bulut filolarını yöneten, kriz anında soğukkanlılıkla doğru kararı veren usta bir sistem mimarısınız! Bir mimarın ustalığı 'en karmaşık sistemi tasarlamak' değil, 'işi çözecek en sade sistemi kurup onun sınırlarını ve bedellerini (Trade-off) savunabilmektir'. Bu son derste öğrendiğimiz tüm ilkeleri zihninizdeki taçla birleştiriyoruz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Congratulations! You have conquered all 60 lessons and reached the summit of distributed systems mastery. You are no longer merely someone who connects software boxes with lines on a whiteboard; you are a battle-tested Staff Systems Architect! The hallmark of true engineering seniority is never building the most convoluted system imaginable; it is designing the simplest system that completely solves the problem while lucidly defending its compromises (Trade-offs). In this grand finale, we synthesize all 60 lessons into your career playbook!]
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
      MAANG Mülakat Komitelerinin Staff+ (L6/L7) Değerlendirme Kriterleri: 1) Bedel Savunması (The 'No Free Lunch' Axiom): Mimaride mükemmel bir çözüm yoktur; her kararın bir bedeli vardır (Örn: 'SQL seçtim çünkü güçlü ACID gerekiyor; bedeli: Sharding karmaşıklığı'). Bir aday 'Benim sistemimin hiçbir eksiği yok' diyorsa elenir. 2) Day-2 Operasyonları: Sistem sadece mutlu yolda değil; sunucu yandığında, ağ bölündüğünde, faturalar şiştiğinde nasıl davranıyor? (Observability, SLOs, Circuit Breaker, FinOps). 3) İletişim ve Liderlik: Mülakatçıyı dinleme, varsayımları seslendirme, karmaşık fikirleri sade benzetmelerle aktarma yeteneği. Bu 60 derslik müfredat, sizi dünyanın en seçkin teknoloji şirketlerinin beyaz tahta mülakatlarına tam donanımlı hazırlamıştır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The Staff+ (L6/L7) Hiring Committee Evaluation Rubric: 1) Trade-Off Fluency (The 'No Free Lunch' Axiom): Engineering is the science of managed compromises. (e.g. 'I chose Cassandra to absorb 1M writes/sec; the explicit compromise is that range scans require multi-partition scatter-gather queries'). Claiming a design has zero drawbacks reveals junior naivety. 2) Day-2 Operational Realism: Mature designs anticipate catastrophic failure: cascading retry storms, regional blackouts, disk full events, and billing alarms. 3) Executive Technical Communication: Driving the whiteboard collaboratively, articulating invariants clearly, and remaining coachable under interrogation. Mastering these 60 lessons positions you at the absolute vanguard of global distributed systems engineering.]
    ]
  )
]

#java25_box[
```java
// Java 25: Staff+ Mühendislik Karar Matrisi ve Trade-Off Değerlendiricisi
public class StaffDecisionMatrix {
    public record ArchitecturalChoice(
        String technology,
        String chosenBenefit,
        String acceptedDrawback,
        String mitigationStrategy
    ) {}

    public static void main(String[] args) {
        var decision = new ArchitecturalChoice(
            "Apache Kafka Event Streaming",
            "Milyonlarca olayı saniyede kayıpsız yutma ve geriye dönük oynatma (Replay)",
            "Nihai tutarlılık (Eventual Consistency) ve tüketici tarafında mükerrerlik riski",
            "Tüketicilerde Idempotency Key ve Dead Letter Queue (DLQ) mekanizması kurmak"
        );

        IO.println("=== STAFF+ MİMARİ KARAR SAVUNMASI ===");
        IO.println("Seçilen Teknoloji: " + decision.technology());
        IO.println("Kazanç (Benefit):  " + decision.chosenBenefit());
        IO.println("Kabul Edilen Bedel:" + decision.acceptedDrawback());
        IO.println("Emniyet Sibobu:    " + decision.mitigationStrategy());
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
      Mülakatın sonunda mülakatçı 'Bana sormak istediğin bir soru var mı?' dediğinde ASLA 'Hayır, her şey netti' deyip susmayın! Staff seviyedeki bir mühendis şirket içi mimari kültür, teknik borçlar veya ölçeklenme zorlukları hakkında derinlikli ve zekice sorular sorar.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never close an interview with 'No questions, everything was clear'. A Staff+ candidate leverages the final 5 minutes to interrogate the interviewer about company-specific distributed consensus challenges, technical debt, or multi-region failover drills.]
    ]
  )
]

#takeaways_box((
    ("Staff+ mühendisin en büyük gücü, mimari kararların getirdiği bedelleri (Trade-Offs) açıkça bilmesidir.", "Staff engineers excel at explicitly identifying and defending architectural trade-offs."),
    ("En iyi sistem en karmaşık olan değil; gereksinimi en sade ve dayanıklı karşılayan sistemdir.", "The superior architecture is not the most complex, but the simplest resilient design."),
    ("60 derslik bu devasa müfredatı tamamlayarak MAANG mülakatlarında zirveye hazırsınız!", "You have conquered all 60 lessons and earned elite mastery in distributed system design!"),
))
