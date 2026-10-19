#import "/template.typ": *

#show: doc => setup_book(title: "Ders 55: Beyaz Tahtada Mülakat Yönetimi: 45 Dakikayı Dakika Dakika Yönetmek", doc)

#lesson_header(
  55,
  "Beyaz Tahtada Mülakat Yönetimi: 45 Dakikayı Dakika Dakika Yönetmek",
  "Managing the 45-Minute Whiteboard Session: Minute-by-Minute Playbook",
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook"
)

#diagram_box[
```text
   [ 45 DAKİKALIK MAANG SİSTEM TASARIMI MÜLAKATI ZAMAN KRONOMETRESİ ]

   00:00 ──▶ [ DAKİKA 0 - 5: GEREKSİNİMLERİ NETLEŞTİR (SCOPE & CLARIFY) ]
             • Fonksiyonel olan ve OLMAYAN (Out-of-Scope) hedefleri sınırla!
             • DAU, QPS ve Read/Write oranını sor ve netleştir.

   05:00 ──▶ [ DAKİKA 5 - 15: YÜKSEK SEVİYE MİMARİ (HIGH-LEVEL DESIGN) ]
             • Kutuları çiz: Client -> DNS/CDN -> LB -> Gateway -> Services -> DB.
             • Uçtan uca mutlu yolu (Happy Path) tamamla!

   15:00 ──▶ [ DAKİKA 15 - 30: DERİNLEMESİNE TASARIM (DEEP DIVE) ]
             • Mülakatçının en çok ilgilendiği 1-2 kritik bileşeni seç ve derinleş!
             • Veri şeması, Sharding Key, Önbellek stratejisi, Konsensüs.

   30:00 ──▶ [ DAKİKA 30 - 40: DARBOĞAZLAR VE DAYANIKLILIK (BOTTLENECK HARDENING) ]
             • Tek Hata Noktaları (SPOFs), Hata Bütçesi, Circuit Breaker, Auto-Scaling.

   40:00 ──▶ [ DAKİKA 40 - 45: ÖZET VE SORULAR (WRAP-UP & QUESTIONS) ]
             • Mimariyi özetle, trade-off'ları açıkla ve mülakatçıya soru sor!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Mülakatı 45 dakikalık bir futbol maçı gibi düşünün: İlk 5 dakika sahayı ve rakibi tanırsınız (Soruları sorar, taktiği belirlersiniz). Sonraki 10 dakika ilk golü atar, tahtaya genel oyun planını çizersiniz (High-Level mimari). Maçın orta kısmında (15-30. dk) en yetenekli forvetinizi sahaya sürer, sistemin en zor parçasının röntgenini çekersiniz (Deep Dive). Son dakikalarda ise defansı sağlama alır, 'Rakip kontra atağa kalkarsa ne yaparız?' diyerek olası arızaları ve yedekleri anlatırsınız (Resilience). Süreyi iyi yöneten maçı 3-0 kazanır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Treat the 45-minute interview like a World Cup final: Minutes 0-5 are feeling out the pitch: ask clarifying questions, set game rules, and lock the scope. Minutes 5-15 score the first goal: sketch the end-to-end high-level happy path from browser to database. Minutes 15-30 showcase your star striker: deep-dive into the single most treacherous bottleneck (sharding, caching, consensus). Minutes 30-40 fortify defense: identify single points of failure and explain how the system survives datacenter outages. The final 5 minutes summarize trade-offs. Flawless time management wins offers!]
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
      MAANG mülakatlarında zaman yönetimi, teknik bilgi kadar belirleyicidir. Adayların %70'i zamanı yönetemediği için elenir (örneğin ilk 25 dakikayı kapasite hesabında harcayıp mimariye geçemezler). 1) Direksiyonu Siz Tutun (Drive the Discussion): Mülakatçı pasif bir dinleyicidir; sizin bir Staff Mühendis gibi mülakatı yapılandırmanızı ve 'Şimdi yüksek seviye mimariyi çiziyorum, ardından izin verirseniz önbellek tutarlılığına derinlemesine ineceğim' diyerek gündemi belirlemenizi bekler. 2) Sinyal Gönderimi (Signaling): Mülakatçının yüz ifadesini ve ipuçlarını okuyun; eğer 'Veri modeline biraz daha bakalım mı?' diyorsa hemen o konuya odaklanın.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Time management in MAANG rounds is an explicit evaluation axis (Leadership & Communication signal). Over 70% of rejections stem from mismanaged pacing (e.g. spending 25 minutes calculating petabytes on napkin math without drawing a single database). 1) Drive the Agenda Proactively: Staff+ candidates command the room: 'I've scoped the core APIs; next, I will sketch the high-level architecture before deep-diving into the fan-out queue. Does that match your expectations?' 2) Pivot on Interviewer Prompts: Interviewers drop hints: 'How does this behave when redis drops?' Do not defend an ego; lean into their prompt and articulate failure modes instantly.]
    ]
  )
]

#java25_box[
```java
// Java 25: Mülakat Zaman Takipçisi ve Aşama Kontrol Modeli
public record InterviewStage(String stageName, int targetMinutes, String primaryDeliverable) {
    public static java.util.List<InterviewStage> getStandardPlaybook() {
        return java.util.List.of(
            new InterviewStage("1. Kapsam & SLA Netleştirme", 5, "Fonksiyonel gereksinimler, DAU, QPS, P99 hedefleri"),
            new InterviewStage("2. Yüksek Seviye Mimari", 10, "Kutuları çiz: Client, CDN, LB, Gateway, Services, DB"),
            new InterviewStage("3. Derinlemesine Tasarım", 15, "Veri şeması, Sharding Key, Önbellek, Olay Akışı"),
            new InterviewStage("4. Darboğaz & Dayanıklılık", 10, "SPOF analizi, Circuit Breaker, Felaket Kurtarma"),
            new InterviewStage("5. Kapanış & Soru-Cevap", 5, "Trade-off özeti ve mülakatçıya teknik sorular")
        );
    }
}

void main() {
    IO.println("=== 45 DAKİKALIK MAANG MÜLAKAT KRONOMETRESİ ===");
    int total = 0;
    for (var stage : InterviewStage.getStandardPlaybook()) {
        total += stage.targetMinutes();
        IO.println("[" + String.format("%02d", total) + " dk] " + stage.stageName() + " ──▶ " + stage.primaryDeliverable());
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
      Mülakatçının 'Bir sonraki adıma geçelim' uyarısına rağmen inatla aynı konuyu uzatmayın! Bu durum 'İletişime kapalı' (Low coachability / stubborn) sinyali verir ve mülakatın doğrudan olumsuz sonuçlanmasına yol açar.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Ignoring an interviewer's gentle nudge ('Let's move on to the storage tier') to keep obsessing over API parameters signals poor coachability and stubbornness. Always acknowledge, pivot, and follow their conversational lead.]
    ]
  )
]

#takeaways_box((
    ("Mülakatın direksiyonunu bir Staff Mühendis gibi nazikçe ve proaktif olarak yönetin.", "Proactively command the interview agenda like an experienced Staff Engineer."),
    ("Kapasite hesaplarında 3 dakikadan fazla oyalanmayın; mimariye hızla geçin.", "Never waste more than 3 minutes on napkin arithmetic; advance to architecture swiftly."),
    ("Son 10 dakikayı mutlaka darboğazları ve hata senaryolarını çözmeye ayırın.", "Reserve the final 10 minutes strictly for hardening failure domains and edge cases."),
))
