# -*- coding: utf-8 -*-
"""
Module 10: Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi (Lessons 55-60)
"""

MODULE = {
    "id": 10,
    "dir": "module_10_interview_mastery",
    "title_tr": "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
    "title_en": "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook",
    "desc_tr": "45 dakikalık mülakatı yönetme sanatı, netleştirme soruları, Zero-Trust ve mTLS güvenliği, Çok Bölgeli (Multi-Region) felaket kurtarma, FinOps bulut maliyeti ve Staff+ Büyük Kapanışı.",
    "desc_en": "Mastering the 45-minute whiteboard session, clarifying questions, Zero-Trust & mTLS, Active-Active Multi-Region DR, Cloud FinOps economics, and the Staff+ Architecture Finale.",
    "lessons": [
        {
            "num": 55,
            "title_tr": "Beyaz Tahtada Mülakat Yönetimi: 45 Dakikayı Dakika Dakika Yönetmek",
            "title_en": "Managing the 45-Minute Whiteboard Session: Minute-by-Minute Playbook",
            "diagram": """   [ 45 DAKİKALIK MAANG SİSTEM TASARIMI MÜLAKATI ZAMAN KRONOMETRESİ ]

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
             • Mimariyi özetle, trade-off'ları açıkla ve mülakatçıya soru sor!""",
            "eli5_tr": "Mülakatı 45 dakikalık bir futbol maçı gibi düşünün: İlk 5 dakika sahayı ve rakibi tanırsınız (Soruları sorar, taktiği belirlersiniz). Sonraki 10 dakika ilk golü atar, tahtaya genel oyun planını çizersiniz (High-Level mimari). Maçın orta kısmında (15-30. dk) en yetenekli forvetinizi sahaya sürer, sistemin en zor parçasının röntgenini çekersiniz (Deep Dive). Son dakikalarda ise defansı sağlama alır, 'Rakip kontra atağa kalkarsa ne yaparız?' diyerek olası arızaları ve yedekleri anlatırsınız (Resilience). Süreyi iyi yöneten maçı 3-0 kazanır!",
            "eli5_en": "Treat the 45-minute interview like a World Cup final: Minutes 0-5 are feeling out the pitch: ask clarifying questions, set game rules, and lock the scope. Minutes 5-15 score the first goal: sketch the end-to-end high-level happy path from browser to database. Minutes 15-30 showcase your star striker: deep-dive into the single most treacherous bottleneck (sharding, caching, consensus). Minutes 30-40 fortify defense: identify single points of failure and explain how the system survives datacenter outages. The final 5 minutes summarize trade-offs. Flawless time management wins offers!",
            "deep_tr": "MAANG mülakatlarında zaman yönetimi, teknik bilgi kadar belirleyicidir. Adayların %70'i zamanı yönetemediği için elenir (örneğin ilk 25 dakikayı kapasite hesabında harcayıp mimariye geçemezler). 1) Direksiyonu Siz Tutun (Drive the Discussion): Mülakatçı pasif bir dinleyicidir; sizin bir Staff Mühendis gibi mülakatı yapılandırmanızı ve 'Şimdi yüksek seviye mimariyi çiziyorum, ardından izin verirseniz önbellek tutarlılığına derinlemesine ineceğim' diyerek gündemi belirlemenizi bekler. 2) Sinyal Gönderimi (Signaling): Mülakatçının yüz ifadesini ve ipuçlarını okuyun; eğer 'Veri modeline biraz daha bakalım mı?' diyorsa hemen o konuya odaklanın.",
            "deep_en": "Time management in MAANG rounds is an explicit evaluation axis (Leadership & Communication signal). Over 70% of rejections stem from mismanaged pacing (e.g. spending 25 minutes calculating petabytes on napkin math without drawing a single database). 1) Drive the Agenda Proactively: Staff+ candidates command the room: 'I've scoped the core APIs; next, I will sketch the high-level architecture before deep-diving into the fan-out queue. Does that match your expectations?' 2) Pivot on Interviewer Prompts: Interviewers drop hints: 'How does this behave when redis drops?' Do not defend an ego; lean into their prompt and articulate failure modes instantly.",
            "java_code": """// Java 25: Mülakat Zaman Takipçisi ve Aşama Kontrol Modeli
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
}""",
            "warning_tr": "Mülakatçının 'Bir sonraki adıma geçelim' uyarısına rağmen inatla aynı konuyu uzatmayın! Bu durum 'İletişime kapalı' (Low coachability / stubborn) sinyali verir ve mülakatın doğrudan olumsuz sonuçlanmasına yol açar.",
            "warning_en": "Ignoring an interviewer's gentle nudge ('Let's move on to the storage tier') to keep obsessing over API parameters signals poor coachability and stubbornness. Always acknowledge, pivot, and follow their conversational lead.",
            "takeaways": [
                ("Mülakatın direksiyonunu bir Staff Mühendis gibi nazikçe ve proaktif olarak yönetin.", "Proactively command the interview agenda like an experienced Staff Engineer."),
                ("Kapasite hesaplarında 3 dakikadan fazla oyalanmayın; mimariye hızla geçin.", "Never waste more than 3 minutes on napkin arithmetic; advance to architecture swiftly."),
                ("Son 10 dakikayı mutlaka darboğazları ve hata senaryolarını çözmeye ayırın.", "Reserve the final 10 minutes strictly for hardening failure domains and edge cases.")
            ]
        },
        {
            "num": 56,
            "title_tr": "Belirsizlik ve Eksik Gereksinim Yönetimi: Soru Sorma Sanatı (Clarifying Questions)",
            "title_en": "Navigating Ambiguity: The Art of Asking Clarifying Questions",
            "diagram": """   [ SORU SORMA SANATI VE GEREKSİNİM DARALTMA ÇEMBERİ ]

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
   └────────────────────────────────────────────────────────────────────────┘""",
            "eli5_tr": "Bir lokantaya girdiğinizde garsona 'Bana yemek getir!' derseniz garson size bakar ve güler: 'Tatlı mı, et mi, çorba mı? Alerjiniz var mı? Bütçeniz ne kadar?' diye sorar. MAANG mülakatçısı da size bilerek 'Bana YouTube yap' der ve arkasına yaslanır. Eğer hemen 'Hemen veritabanı çiziyorum' derseniz garsona 'Bana rastgele bir şey getir' diyen acemi müşteri gibi olursunuz! Usta bir mühendis mülakatçıya doğru soruları sorarak sınırları çizer: 'Canlı yayın mı, kayıtlı video mu? Global mi, yerel mi?'",
            "eli5_en": "If you sit down at a 5-star restaurant and bark: 'Bring me food!', the waiter stares back baffled: 'Steak, seafood, or pasta? Do you have peanut allergies? Are we dining fast or celebratory?' MAANG interviewers intentionally throw ultra-vague prompts like 'Design Uber' and lean back to watch your reaction. Leaping straight into drawing databases marks you as a reactive junior. A seasoned engineer unpacks ambiguity with surgical questions: 'Are we optimizing for ride dispatching or driver onboarding? Real-time tracking or fare billing?'",
            "deep_tr": "Belirsizlik Yönetimi (Ambiguity Navigation) MAANG değerlendirme matrisinde L5/L6 (Senior/Staff) terfi kriterinin temelidir. Mülakatçı gereksinimleri bilerek eksik bırakır; amacı adayın belirsizlik karşısındaki mühendislik olgunluğunu ölçmektir. Sorulması Gereken 4 Boyutlu Sorular: 1) Kullanıcı & Fonksiyonel Kapsam: Temel 2-3 kullanım senaryosu nedir? Kapsam dışı (Out of Scope) bırakacağımız özellikler nelerdir? 2) Ölçek (Scale): DAU (Günlük Aktif Kullanıcı), QPS, Read-to-Write oranı. 3) Ağ ve Cihaz Kısıtları: Mobil istemciler zayıf 3G/4G ağlarda mı çalışacak? 4) Güvenilirlik & Tutarlılık (SLAs): Güçlü tutarlılık mı (ACID), yoksa yüksek erişilebilirlik ve nihai tutarlılık mı (BASE)?",
            "deep_en": "Ambiguity Navigation is a tier-one rubric in L5/L6 (Senior/Staff) hiring committees. Real production problems arrive without specifications. Interviewers simulate this by withholding context. Systematic Clarification Matrix: 1) Core User Persona: What are the primary 2-3 user journeys? What are we explicitly declaring OUT OF SCOPE? (e.g. 'We will omit video recommendations and user comments today'). 2) Scale Envelope: Daily Active Users, Peak write/read QPS, average payload size. 3) Client Environmental Constraints: Mobile networks with flaky connectivity requiring offline caching and resume capability? 4) Latency & Consistency Constraints: P99 bounds, strict consistency vs eventual consistency.",
            "java_code": """// Java 25: Mülakat Kapsam Sözleşmesi Modeli (Scope Contract)
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
}""",
            "warning_tr": "Mülakatçıya 50 tane gereksiz detay soru sorup 'Analysis Paralysis' (analiz felci) yaşamayın! Sorularınızı 4-5 kritik soruyla sınırlayın, ardından 'Eğer onaylarsanız bu varsayımlarla devam etmek istiyorum' diyerek inisiyatif alın.",
            "warning_en": "Avoid Analysis Paralysis by firing 40 trivial questions. Cap clarifications at 4-5 strategic questions, state reasonable engineering assumptions, and proactively validate: 'Unless you prefer otherwise, I will assume 100M DAU and proceed.'",
            "takeaways": [
                ("Mülakatçı soruyu bilerek muğlak sorar; amacı belirsizlik yönetimini ölçmektir.", "Vague prompts are intentional tests to evaluate how you structure architectural chaos."),
                ("Kapsam dışı (Out-of-Scope) bırakılan özellikleri mülakatın başında açıkça belirleyin.", "Explicitly declare Out-of-Scope features early to shield precious time."),
                ("Varsayımlarınızı sesli olarak ifade edip mülakatçının onayını alarak ilerleyin.", "State architectural assumptions out loud and confirm alignment with the interviewer.")
            ]
        },
        {
            "num": 57,
            "title_tr": "Güvenlik, Kimlik ve Uyumluluk: OAuth2, mTLS, Zero-Trust ve GDPR",
            "title_en": "Security, Identity & Compliance: OAuth2, mTLS, Zero-Trust & GDPR",
            "diagram": """   [ KURUMSAL SIFIR GÜVEN (ZERO-TRUST) VE MTLS MİMARİSİ ]

   [Dış İstemci] ──HTTPS (TLS 1.3) + OAuth2 Bearer Token──▶ [ API GATEWAY ]
                                                                   │
                                                                   ▼ mTLS (Karşılıklı Kimlik Doğrulama)
   ┌─────────────────────────────────────────────────────────────────────────────┐
   │ HİZMET AĞI (SERVICE MESH - ENVOY SIDECARS / ISTIO)                          │
   │ Service A ◀════ mTLS Çift Yönlü X.509 Kriptografik Tünel ════▶ Service B    │
   │ (İç ağdaki tüm mikroservisler birbirini şifreli sertifikayla doğrular!)     │
   └───────────────────────────────────┬─────────────────────────────────────────┘
                                       │
                                       ▼ Veritabanı Şifreleme (AES-256)
   ┌─────────────────────────────────────────────────────────────────────────────┐
   │ VERİTABANI: Rest-at-Encryption (AES-256) + PII Maskeleme (GDPR Uyumlu)      │
   │ Kredi Kartı: "**** **** **** 9481" | TC/SSN: Hashed with Salt               │
   └─────────────────────────────────────────────────────────────────────────────┘""",
            "eli5_tr": "Eski kale modelinde kalenin etrafında derin bir su hendeği ve tek bir asma kapı vardı (Ağ Güvenlik Duvarı - Firewall). Kapıdan içeri bir kez giren casus, kalenin içindeki tüm odalara elini kolunu sallayarak girerdi! Modern Sıfır Güven (Zero-Trust) mimarisi ise şudur: Kalenin içinde bile olsanız, mutfağa girerken mutfak kapısındaki güvenlik görevlisine kimlik gösterirsiniz, kütüphaneye girerken kütüphaneciye parmak izi verirsiniz (mTLS). Kimse kimseye babasının oğlu gibi güvenmez; her oda her kapıda şifrelenir!",
            "eli5_en": "Legacy security relied on the 'Castle-and-Moat' model: a deep perimeter moat and a single drawbridge (Corporate Firewall). Once a hacker sneaked past the drawbridge, they roamed internal palace corridors unhindered! Modern Zero-Trust architecture abandons perimeter trust completely: Even if you sit inside the inner castle corridor, entering the kitchen requires a biometric badge, and entering the treasury requires an armed escort (Mutual TLS / mTLS). Inside a Zero-Trust network, services verify cryptographic identities for every internal hop!",
            "deep_tr": "MAANG Güvenlik ve Uyumluluk Mimarisi Direkleri: 1) Zero-Trust & mTLS (Mutual TLS): 'Ağ içindekilere güven' varsayımı çökmüştür. Mikroservisler arası tüm iletişim Envoy/Istio Service Mesh üzerinden çift yönlü X.509 sertifika doğrulamasıyla (mTLS) şifrelenir. 2) OAuth 2.0 & OIDC: İstemci yetkilendirmesi için PKCE (Proof Key for Code Exchange) destekli Authorization Code Flow; servisler arası iletişim için JWT tabanlı Client Credentials. 3) GDPR ve PII (Personally Identifiable Information) Uyumluluğu: 'Unutulma Hakkı' (Right to be Forgotten) için kullanıcı verileri kriptografik olarak silinebilir (Crypto-Shredding: Kullanıcının özel şifreleme anahtarı silindiğinde veritabanındaki şifreli veri anında anlamsız çöp haline gelir). 4) Data at Rest Encryption: Veritabanı diskleri AES-256 ve AWS KMS / HashiCorp Vault anahtarlarıyla şifrelenir.",
            "deep_en": "Enterprise Security & Compliance Framework: 1) Zero-Trust & Mutual TLS (mTLS): Eliminates internal network perimeter trust. Microservices authenticate reciprocally via X.509 certificates managed by Istio/SPIFFE, ensuring all transit traffic is cryptographically sealed with ephemeral keys. 2) Modern Identity (OAuth 2.1 & OpenID Connect): Public mobile clients employ PKCE Authorization Code flows; internal machine-to-machine transit uses short-lived JWTs signed by asymmetric public/private keys. 3) GDPR & PII Protection via Crypto-Shredding: When a user exercises their GDPR 'Right to be Forgotten', scrubbing distributed backups is nearly impossible. Instead, encrypt the user's PII with a unique per-user DEK (Data Encryption Key). Deleting the key in KMS permanently renders all historical multi-region database and backup records irreversible garbage. 4) Encryption in Transit & at Rest: Enforce TLS 1.3 across the wire and AES-256 disk volume encryption backed by Hardware Security Modules (HSM).",
            "java_code": """// Java 25: GDPR Uyumlu Kriptografik Veri Maskeleme (PII Data Masking)
public class PiiMasker {
    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "*****";
        var parts = email.split("@");
        String name = parts[0];
        String maskedName = name.charAt(0) + "***" + (name.length() > 1 ? name.charAt(name.length() - 1) : "");
        return maskedName + "@" + parts[1];
    }

    public static String maskCreditCard(String pan) {
        if (pan == null || pan.length() < 10) return "****";
        return "****-****-****-" + pan.substring(pan.length() - 4);
    }
}

void main() {
    String rawEmail = "aliturgutbozkurt@example.com";
    String rawCard = "4543123456789481";

    IO.println("Maskelenmiş E-posta: " + PiiMasker.maskEmail(rawEmail));
    IO.println("Maskelenmiş Kredi Kartı: " + PiiMasker.maskCreditCard(rawCard));
}""",
            "warning_tr": "Mülakatta 'İç ağımız zaten güvenli, mikroservisler arasında şifreleme yapmaya gerek yok' demeyin! Modern MAANG standartlarında 'Zero-Trust' esastır; iç ağdaki her istek mTLS ile şifrelenmeli ve doğrulanmalıdır.",
            "warning_en": "Never state that internal microservices communicate in unencrypted plain HTTP because they are 'inside the private VPC'. Staff engineers mandate Zero-Trust: all internal mesh transit must be encrypted via mTLS.",
            "takeaways": [
                ("Zero-Trust felsefesi ağın içindeki hiçbir servise ön koşulsuz güvenmez.", "Zero-Trust assumes the internal network is hostile, verifying every request cryptographically."),
                ("mTLS (Karşılıklı TLS) mikroservislerin birbirini X.509 sertifikalarıyla doğrulamasını sağlar.", "Mutual TLS enforces reciprocal cryptographic authentication across service mesh pods."),
                ("Crypto-Shredding tekniği GDPR 'unutulma hakkını' dağıtık yedeklerde bile saniyede çözer.", "Crypto-shredding satisfies GDPR deletion by destroying user-specific encryption keys.")
            ]
        },
        {
            "num": 58,
            "title_tr": "Felaket Kurtarma ve Çok Bölgeli Mimari: Active-Active vs Active-Passive",
            "title_en": "Disaster Recovery & Multi-Region: Active-Active vs Active-Passive",
            "diagram": """   [ 1. ACTIVE-PASSIVE (Korumalı / Hot Standby) ]
   Kullanıcılar ──▶ [ Region 1 (Aktif - Frankfurt) ] ──Asenkron Sync──▶ [ Region 2 (Pasif - İrlanda) ]
   (Bölge 1 çökerse DNS Region 2'ye yönlendirilir. RPO: ~5 dk veri kaybı, RTO: ~10 dk kesinti)

   [ 2. ACTIVE-ACTIVE (Çok Bölgeli Canlı - Multi-Region Active) ]
   Avrupa Kullanıcıları ──▶ [ Region 1 (Frankfurt) ] ◀──┐
                                                         ├── Çift Yönlü Eşleme (Bi-directional Sync)
   Asya Kullanıcıları   ──▶ [ Region 2 (Singapur)  ] ◀──┘
   (İki bölge de aynı anda canlıdır! Biri çökerse sıfır kesintiyle diğeri karşılar!)""",
            "eli5_tr": "Felaket kurtarma modellerini iki farklı araba lastiği gibi düşünün: 1) Active-Passive: Arabanın bagajındaki yedek lastiktir (Stepne). Bagajda hazır bekler; yoldaki lastik patlarsa arabayı durdurur, krikoyu kaldırır, stepneyi takarsınız (15 dakika vakit kaybedersiniz - RTO). 2) Active-Active: 8 tekerlekli dev bir maden kamyonudur! 8 tekerleğin hepsi aynı anda döner. Tekerleklerden biri patlasa bile kamyon durmaz, hızını hiç kesmeden yoluna devam eder! Ancak 8 tekerleğin de aynı hızda dönmesini sağlamak (Veri senkronizasyonu) çok daha büyük bir mühendislik ister!",
            "eli5_en": "Compare disaster recovery to vehicular resilience: 1) Active-Passive is carrying a spare tire in your car trunk. It sits idle. When your front tire blows out, you must pull over, hoist the jack, and bolt on the spare (15 minutes of downtime - RTO). 2) Active-Active is an 8-wheeled military assault vehicle: All 8 wheels drive concurrently. If tire #3 gets shot out by a landmine, the vehicle doesn't stop for a single second; it barrels forward uninterrupted! However, keeping all 8 wheels synchronized across diverse terrain (bi-directional cross-region replication) requires supreme engineering discipline!",
            "deep_tr": "MAANG Felaket Kurtarma (Disaster Recovery - DR) Metrikleri ve Modelleri: 1) İki Kritik Metrik: A) RPO (Recovery Point Objective): Felaket anında kabul edilebilir maksimum veri kaybı süresi (ör. 'Son 1 dakikalık veri kaybolabilir'). B) RTO (Recovery Time Objective): Sistemin ayağa kalkması için izin verilen maksimum kesinti süresi (ör. 'Sistem 5 dakikada geri dönmeli'). 2) Active-Passive (Warm/Hot Standby): Trafik tek bir ana bölgeye (Primary) akar; veriler ikincil bölgeye (Secondary) asenkron replike edilir. Maliyeti düşüktür ancak failover sırasında RPO > 0 ve RTO gecikmesi yaşanır. 3) Multi-Region Active-Active: Her iki bölge de canlı trafik alır. Avantajı: Sıfır RTO (biri çökerse Anycast DNS veya Global Accelerator trafiği anında diğer bölgeye aktarır). Zorluğu: Çift yönlü veritabanı replikasyonu (Multi-Master / CockroachDB / Spanner) ve çakışma çözümü (Conflict Resolution: CRDTs).",
            "deep_en": "Disaster Recovery Frameworks & Metrics: 1) RPO (Recovery Point Objective): The maximum tolerable temporal window of data loss measured in time (e.g. RPO = 5 seconds means mutations older than 5s are safely preserved). 2) RTO (Recovery Time Objective): The maximum permissible duration the system can remain offline before restoration (e.g. RTO = 2 minutes). 3) Active-Passive Topology: Primary region serves 100% of traffic, streaming snapshots and WAL logs to a secondary warm standby. Cost-effective, but failover requires DNS propagation delays and risks data loss on inflight replication buffers. 4) Multi-Region Active-Active: Multiple geographic regions simultaneously ingest live traffic. Traffic fails over seamlessly with zero RTO via Anycast BGP shifts. The engineering hurdle: cross-datacenter multi-master write conflict resolution, solved via Conflict-Free Replicated Data Types (CRDTs) or globally coordinated consensus databases (Google Cloud Spanner, CockroachDB).",
            "java_code": """// Java 25: RPO ve RTO Felaket Kurtarma Hedef Modeli
public record DisasterRecoveryPlan(
    String strategyName,
    int rpoSeconds,
    int rtoSeconds,
    boolean supportsZeroDowntimeFailover
) {
    public void printDrProfile() {
        IO.println("Strateji:        " + strategyName);
        IO.println("Maks Veri Kaybı: " + rpoSeconds + " saniye (RPO)");
        IO.println("Maks Kesinti:    " + rtoSeconds + " saniye (RTO)");
        IO.println("Sıfır Kesinti:   " + supportsZeroDowntimeFailover);
    }
}

void main() {
    var activePassive = new DisasterRecoveryPlan("Active-Passive Hot Standby", 60, 300, false);
    var activeActive = new DisasterRecoveryPlan("Active-Active Multi-Region", 0, 0, true);

    IO.println("--- Active-Passive Profili ---");
    activePassive.printDrProfile();
    IO.println("\\n--- Active-Active Profili ---");
    activeActive.printDrProfile();
}""",
            "warning_tr": "Mülakatta hemen 'Active-Active kurarım' demeyin! Çok bölgeli Active-Active mimari korkunç derecede pahalıdır ve iki bölge arasında ışık hızı gecikmesi yüzünden veri çakışmaları (Write Conflicts) çıkar. Mülakatçıya önce maliyet/fayda analizini yapıp kritiklik seviyesine göre Active-Passive veya Active-Active önereceğinizi belirtin.",
            "warning_en": "Never jump immediately to Multi-Region Active-Active without acknowledging costs. Cross-region data egress fees, distributed locking latency, and split-brain risks can multiply operating budgets by 5x. Always balance RPO/RTO business value against cost.",
            "takeaways": [
                ("RPO izin verilen veri kaybı süresini, RTO ise sistemin geri dönme süresini belirtir.", "RPO bounds tolerable data loss in seconds; RTO defines maximum acceptable downtime."),
                ("Active-Passive daha ucuz ve basittir ancak failover sırasında kısa bir kesinti yaşatır.", "Active-Passive minimizes infrastructure costs while accepting brief failover lag."),
                ("Active-Active sıfır kesinti (Zero RTO) sağlar ancak çift yönlü veri çakışması yönetimi gerektirir.", "Active-Active delivers instantaneous failover at the cost of cross-region write synchronization.")
            ]
        },
        {
            "num": 59,
            "title_tr": "Maliyet Optimizasyonu ve Bulut Ekonomisi (FinOps): Egress, Spot ve Tiering",
            "title_en": "Cloud Economics & FinOps: Egress Costs, Spot Instances & Data Tiering",
            "diagram": """   [ BULUT MALİYET OPTİMİZASYON PİRAMİDİ (FINOPS STRATEJİSİ) ]

   1. AĞ MALİYETİ (EGRESS)     : İnternete veri çıkarmak ($0.09/GB) ÇOK PAHALIDIR!
                                 Çözüm: CDN önbellekleme ve sıkıştırma (Gzip/Brotli/ZSTD)
   2. HESAPLAMA (COMPUTE)      : Sürekli On-Demand makine çalıştırmak israftır!
                                 Çözüm: Spot/Preemptible makineler (%70-90 indirim!)
   3. VERİ SAKLAMA (STORAGE)   : Tüm veriyi pahalı SSD'de tutmak maliyet intiharıdır!
                                 Çözüm: Yaşam Döngüsü (Lifecycle Tiering): Hot -> Warm -> Glacier""",
            "eli5_tr": "Bir şirkette elektrik ve su faturalarını yönettiğinizi düşünün: 1) İnternet Çıkış Ücreti (Egress): Evinize su almak bedavadır ama dışarıya her kova su boşalttığınızda su idaresi sizden 10 TL para alır! Bulut sağlayıcıları da (AWS, Google Cloud) içeri veri alırken para almaz ama dışarıya çıkan her gigabayttan (Egress) servet kazanır. 2) Spot Makineler: Uçaktaki son dakika boş koltukları gibidir; havayolu koltuk boş gitmesin diye %80 indirimle satar! Siz de arka planda video kodlayan sunucuları bu indirimli Spot makinelerden seçersiniz. 3) Arşiv Depolama: 5 yıl önceki faturaları lüks bir gökdelende değil, şehir dışındaki ucuz bir depoda (AWS Glacier) saklamaktır!",
            "eli5_en": "Think of managing utility bills for a massive industrial complex: 1) Egress Bandwidth: Pumping water into your reservoir is free, but dumping water back into the city pipes incurs a $10 penalty per bucket! Cloud providers (AWS, GCP) charge zero for data ingress, but levy eye-watering tolls on every gigabyte exiting their network (Egress). 2) Spot Instances: Standby standby airline tickets sold at an 80% discount 20 minutes before takeoff. Use Spot nodes for asynchronous video transcoding or batch training! 3) Storage Tiering: Storing 5-year-old tax audits inside expensive downtown prime real estate (NVMe SSD) is financial suicide; move them to a dusty underground warehouse in the desert (AWS Glacier)!",
            "deep_tr": "MAANG Seviyesi FinOps Mimarisi: 1) Egress Trafik Tuzağı: Bulutta bölgeler arası (Cross-Region) veya internete çıkan veri en pahalı kalemdir ($0.08 - $0.12 / GB). Çözüm: CDN kullanımıyla origin egress'ini %90 düşürmek, aynı kullanılabilirlik alanında (AZ) kalmak ve gRPC/Protobuf/ZSTD ile veriyi sıkıştırmak. 2) Spot / Preemptible Örnekler: AWS ve GCP'nin boşta duran kapasitesini %70-%90 indirimle sunmasıdır. Sağlayıcı makineyi 2 dakika önceden haber vererek geri alabilir. Durumsuz işçiler (Video Transcoding, ML eğitimi, Batch Job) için kusursuzdur. 3) S3 Yaşam Döngüsü (Lifecycle Tiering): S3 Standard ($0.023/GB) -> S3 Infrequent Access ($0.0125/GB) -> S3 Glacier Flexible ($0.0036/GB) -> S3 Glacier Deep Archive ($0.00099/GB). 90 günden eski loglar Glacier'a atılarak depolama maliyeti 23 kat düşürülür!",
            "deep_en": "MAANG Cloud FinOps Disciplines: 1) The Egress Bandit: Cloud providers charge zero for inbound traffic, but penalize internet and cross-region egress with steep fees ($0.08-$0.12/GB). Solutions: Maximize CDN cache offloading, enforce colocation within identical Availability Zones, and mandate Protobuf with Zstandard compression. 2) Spot / Preemptible Fleet Arbitrage: Cloud vendors auction spare compute at 70%-90% discounts with a 2-minute preemption warning. Ideal for stateless, containerized worker pools (video transcoding, model inference, background queue drainers) orchestrated by Kubernetes Karpenter. 3) Object Storage Lifecycle Tiering: S3 Standard ($0.023/GB) transitions automatically after 30 days to Infrequent Access ($0.0125/GB), then after 90 days to Glacier Flexible ($0.0036/GB), and finally to Glacier Deep Archive ($0.00099/GB). Slashes cold storage expenditure by 95% while retaining compliance guarantees.",
            "java_code": """// Java 25: S3 Depolama Katmanlama (Tiering) Maliyet Karşılaştırma Modeli
public class FinOpsStorageCalculator {
    public static double calculateMonthlyCost(double terabytes, String tier) {
        double costPerGb = switch (tier) {
            case "S3_STANDARD"     -> 0.023;
            case "S3_INFREQUENT"   -> 0.0125;
            case "S3_GLACIER"      -> 0.0036;
            case "GLACIER_DEEP"    -> 0.00099;
            default                -> 0.023;
        };
        return (terabytes * 1024) * costPerGb;
    }
}

void main() {
    double tb = 100.0; // 100 Terabayt Veri
    double standardCost = FinOpsStorageCalculator.calculateMonthlyCost(tb, "S3_STANDARD");
    double deepArchiveCost = FinOpsStorageCalculator.calculateMonthlyCost(tb, "GLACIER_DEEP");

    IO.println("100 TB S3 Standard Aylık Maliyet:     $" + String.format("%.2f", standardCost));
    IO.println("100 TB Glacier Deep Aylık Maliyet:    $" + String.format("%.2f", deepArchiveCost));
    IO.println("Aylık Tasarruf Oranı: %" + String.format("%.1f", (1.0 - (deepArchiveCost / standardCost)) * 100));
}""",
            "warning_tr": "Mülakatta 'Maliyeti hiç düşünmem, her yere en pahalı AWS sunucularını ve 100 replika koyarım' demeyin! Staff ve Principal seviyesindeki mühendisler mimariyi sadece performans için değil, şirket bütçesini ve bulut maliyetlerini (Unit Economics) korumak için tasarlar.",
            "warning_en": "Dismissing cloud costs in an interview as 'someone else's problem' guarantees an L4 downgrade. Staff and Principal engineers distinguish themselves by anchoring technical architectures to cloud unit economics and FinOps efficiency.",
            "takeaways": [
                ("Egress trafiği bulut faturalarının en tehlikeli ve gizli maliyet kalemidir.", "Network egress is the single most expensive hidden trap in cloud architecture."),
                ("Spot makineler durumsuz iş yüklerinde maliyetleri %80'e varan oranda düşürür.", "Spot compute instances deliver up to 80% cost savings for fault-tolerant background workloads."),
                ("Otomatik S3 Lifecycle kuralları soğuk verileri Glacier'a taşıyarak %95 tasarruf sağlar.", "S3 lifecycle tiering transitions cold historical logs into deep archive, saving 95%.")
            ]
        },
        {
            "num": 60,
            "title_tr": "Büyük Kurumsal Final: Staff+ Zihniyeti, Trade-Off Savunması ve Mülakat Altın Rehberi",
            "title_en": "Grand Enterprise Finale: The Staff+ Mindset, Trade-Off Mastery & Golden Rubric",
            "diagram": """   [ MAANG STAFF+ SİSTEM TASARIMI BAŞARI MATRİSİ (THE GOLDEN RUBRIC) ]

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
                     └──────────────────────────────────────────────────┘""",
            "eli5_tr": "Tebrikler! 60 derslik muazzam bir yolculuğun zirvesine ulaştınız. Artık sistem tasarımına sadece 'kutular çizip aralarına oklar koyan' bir yazılımcı olarak bakmıyorsunuz; devasa bulut filolarını yöneten, kriz anında soğukkanlılıkla doğru kararı veren usta bir sistem mimarısınız! Bir mimarın ustalığı 'en karmaşık sistemi tasarlamak' değil, 'işi çözecek en sade sistemi kurup onun sınırlarını ve bedellerini (Trade-off) savunabilmektir'. Bu son derste öğrendiğimiz tüm ilkeleri zihninizdeki taçla birleştiriyoruz!",
            "eli5_en": "Congratulations! You have conquered all 60 lessons and reached the summit of distributed systems mastery. You are no longer merely someone who connects software boxes with lines on a whiteboard; you are a battle-tested Staff Systems Architect! The hallmark of true engineering seniority is never building the most convoluted system imaginable; it is designing the simplest system that completely solves the problem while lucidly defending its compromises (Trade-offs). In this grand finale, we synthesize all 60 lessons into your career playbook!",
            "deep_tr": "MAANG Mülakat Komitelerinin Staff+ (L6/L7) Değerlendirme Kriterleri: 1) Bedel Savunması (The 'No Free Lunch' Axiom): Mimaride mükemmel bir çözüm yoktur; her kararın bir bedeli vardır (Örn: 'SQL seçtim çünkü güçlü ACID gerekiyor; bedeli: Sharding karmaşıklığı'). Bir aday 'Benim sistemimin hiçbir eksiği yok' diyorsa elenir. 2) Day-2 Operasyonları: Sistem sadece mutlu yolda değil; sunucu yandığında, ağ bölündüğünde, faturalar şiştiğinde nasıl davranıyor? (Observability, SLOs, Circuit Breaker, FinOps). 3) İletişim ve Liderlik: Mülakatçıyı dinleme, varsayımları seslendirme, karmaşık fikirleri sade benzetmelerle aktarma yeteneği. Bu 60 derslik müfredat, sizi dünyanın en seçkin teknoloji şirketlerinin beyaz tahta mülakatlarına tam donanımlı hazırlamıştır.",
            "deep_en": "The Staff+ (L6/L7) Hiring Committee Evaluation Rubric: 1) Trade-Off Fluency (The 'No Free Lunch' Axiom): Engineering is the science of managed compromises. (e.g. 'I chose Cassandra to absorb 1M writes/sec; the explicit compromise is that range scans require multi-partition scatter-gather queries'). Claiming a design has zero drawbacks reveals junior naivety. 2) Day-2 Operational Realism: Mature designs anticipate catastrophic failure: cascading retry storms, regional blackouts, disk full events, and billing alarms. 3) Executive Technical Communication: Driving the whiteboard collaboratively, articulating invariants clearly, and remaining coachable under interrogation. Mastering these 60 lessons positions you at the absolute vanguard of global distributed systems engineering.",
            "java_code": """// Java 25: Staff+ Mühendislik Karar Matrisi ve Trade-Off Değerlendiricisi
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
}""",
            "warning_tr": "Mülakatın sonunda mülakatçı 'Bana sormak istediğin bir soru var mı?' dediğinde ASLA 'Hayır, her şey netti' deyip susmayın! Staff seviyedeki bir mühendis şirket içi mimari kültür, teknik borçlar veya ölçeklenme zorlukları hakkında derinlikli ve zekice sorular sorar.",
            "warning_en": "Never close an interview with 'No questions, everything was clear'. A Staff+ candidate leverages the final 5 minutes to interrogate the interviewer about company-specific distributed consensus challenges, technical debt, or multi-region failover drills.",
            "takeaways": [
                ("Staff+ mühendisin en büyük gücü, mimari kararların getirdiği bedelleri (Trade-Offs) açıkça bilmesidir.", "Staff engineers excel at explicitly identifying and defending architectural trade-offs."),
                ("En iyi sistem en karmaşık olan değil; gereksinimi en sade ve dayanıklı karşılayan sistemdir.", "The superior architecture is not the most complex, but the simplest resilient design."),
                ("60 derslik bu devasa müfredatı tamamlayarak MAANG mülakatlarında zirveye hazırsınız!", "You have conquered all 60 lessons and earned elite mastery in distributed system design!")
            ]
        }
    ]
}
