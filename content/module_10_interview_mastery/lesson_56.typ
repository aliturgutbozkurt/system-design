#import "/template.typ": *

#show: doc => setup_book(title: "Ders 56: Belirsizlik ve Eksik Gereksinim Yönetimi: Soru Sorma Sanatı (Clarifying Questions)", doc)

#lesson_header(
  56,
  "Belirsizlik ve Eksik Gereksinim Yönetimi: Soru Sorma Sanatı (Clarifying Questions)",
  "Navigating Ambiguity: The Art of Asking Clarifying Questions",
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook"
)

#diagram_box[
```text
   [ SORU SORMA SANATI VE GEREKSİNİM DARALTMA ÇEMBERİ ]

           Mülakatçı Sorusu: "Bana YouTube Tasarla!" (BİLEREK ÇOK GENİŞ!)
                                     │
                                     ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ 1. KAPSAM DARALTMA (SCOPE SCOPING)                                     │
   │ "YouTube devasa bir ekosistem. Bugün video yükleme ve izleme akışına   │
   │ mı odaklanalım, yoksa yorumlar ve canlı yayın mimarisine mi?"          │
   └─────────────────────────────────┬──────────────────────────────────────┘
                                     │
                                     ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ 2. ÖLÇEK VE TRAFİK (SCALE & CAPACITY)                                  │
   │ "Hedef kitlemiz nedir? Günlük 500M izlenme ve 10M yükleme kabul edelim │
   │ mi? Okuma/Yazma oranımız ~50:1 seviyesinde mi?"                        │
   └─────────────────────────────────┬──────────────────────────────────────┘
                                     │
                                     ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ 3. SLA VE GECİKME (NON-FUNCTIONAL BOUNDS)                              │
   │ "Video akışında P99 gecikme hedefimiz <200ms ve 99.99% erişilebilirlik │
   │ midir? Telif hakkı kontrolü asenkron mu yapılmalıdır?"                 │
   └────────────────────────────────────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir lokantaya girdiğinizde garsona 'Bana yemek getir!' derseniz garson size bakar ve güler: 'Tatlı mı, et mi, çorba mı? Alerjiniz var mı? Bütçeniz ne kadar?' diye sorar. MAANG mülakatçısı da size bilerek 'Bana YouTube yap' der ve arkasına yaslanır. Eğer hemen 'Hemen veritabanı çiziyorum' derseniz garsona 'Bana rastgele bir şey getir' diyen acemi müşteri gibi olursunuz! Usta bir mühendis mülakatçıya doğru soruları sorarak sınırları çizer: 'Canlı yayın mı, kayıtlı video mu? Global mi, yerel mi?'
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[If you sit down at a 5-star restaurant and bark: 'Bring me food!', the waiter stares back baffled: 'Steak, seafood, or pasta? Do you have peanut allergies? Are we dining fast or celebratory?' MAANG interviewers intentionally throw ultra-vague prompts like 'Design Uber' and lean back to watch your reaction. Leaping straight into drawing databases marks you as a reactive junior. A seasoned engineer unpacks ambiguity with surgical questions: 'Are we optimizing for ride dispatching or driver onboarding? Real-time tracking or fare billing?']
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
      Belirsizlik Yönetimi (Ambiguity Navigation) MAANG değerlendirme matrisinde L5/L6 (Senior/Staff) terfi kriterinin temelidir. Mülakatçı gereksinimleri bilerek eksik bırakır; amacı adayın belirsizlik karşısındaki mühendislik olgunluğunu ölçmektir. Sorulması Gereken 4 Boyutlu Sorular: 1) Kullanıcı & Fonksiyonel Kapsam: Temel 2-3 kullanım senaryosu nedir? Kapsam dışı (Out of Scope) bırakacağımız özellikler nelerdir? 2) Ölçek (Scale): DAU (Günlük Aktif Kullanıcı), QPS, Read-to-Write oranı. 3) Ağ ve Cihaz Kısıtları: Mobil istemciler zayıf 3G/4G ağlarda mı çalışacak? 4) Güvenilirlik & Tutarlılık (SLAs): Güçlü tutarlılık mı (ACID), yoksa yüksek erişilebilirlik ve nihai tutarlılık mı (BASE)?
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Ambiguity Navigation is a tier-one rubric in L5/L6 (Senior/Staff) hiring committees. Real production problems arrive without specifications. Interviewers simulate this by withholding context. Systematic Clarification Matrix: 1) Core User Persona: What are the primary 2-3 user journeys? What are we explicitly declaring OUT OF SCOPE? (e.g. 'We will omit video recommendations and user comments today'). 2) Scale Envelope: Daily Active Users, Peak write/read QPS, average payload size. 3) Client Environmental Constraints: Mobile networks with flaky connectivity requiring offline caching and resume capability? 4) Latency & Consistency Constraints: P99 bounds, strict consistency vs eventual consistency.]
    ]
  )
]

#java25_box[
```java
// Java 25: Mülakat Kapsam Sözleşmesi Modeli (Scope Contract)
import java.util.List;

public record SystemScopeContract(
    String systemName,
    List<String> inScopeFeatures,
    List<String> outOfScopeFeatures,
    long dailyActiveUsers,
    int peakQps
) {
    public void printContractSummary() {
        IO.println("=== MÜLAKAT KAPSAM SÖZLEŞMESİ: " + systemName + " ===");
        IO.println("Dahil Edilenler (In-Scope):      " + inScopeFeatures);
        IO.println("Kapsam Dışı (Out-of-Scope):      " + outOfScopeFeatures);
        IO.println("Ölçek Parametreleri:             " + dailyActiveUsers + " DAU | Zirve QPS: " + peakQps);
    }
}

void main() {
    var youtubeScope = new SystemScopeContract(
        "YouTube Video Platformu",
        List.of("Video Yükleme", "Adaptif Akış (HLS)", "İzleme Sayacı"),
        List.of("Yorumlar", "Sosyal Beğeniler", "Canlı Yayın", "Öneri Algoritması"),
        500_000_000L,
        150_000
    );
    youtubeScope.printContractSummary();
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
      Mülakatçıya 50 tane gereksiz detay soru sorup 'Analysis Paralysis' (analiz felci) yaşamayın! Sorularınızı 4-5 kritik soruyla sınırlayın, ardından 'Eğer onaylarsanız bu varsayımlarla devam etmek istiyorum' diyerek inisiyatif alın.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Avoid Analysis Paralysis by firing 40 trivial questions. Cap clarifications at 4-5 strategic questions, state reasonable engineering assumptions, and proactively validate: 'Unless you prefer otherwise, I will assume 100M DAU and proceed.']
    ]
  )
]

#takeaways_box((
    ("Mülakatçı soruyu bilerek muğlak sorar; amacı belirsizlik yönetimini ölçmektir.", "Vague prompts are intentional tests to evaluate how you structure architectural chaos."),
    ("Kapsam dışı (Out-of-Scope) bırakılan özellikleri mülakatın başında açıkça belirleyin.", "Explicitly declare Out-of-Scope features early to shield precious time."),
    ("Varsayımlarınızı sesli olarak ifade edip mülakatçının onayını alarak ilerleyin.", "State architectural assumptions out loud and confirm alignment with the interviewer."),
))
