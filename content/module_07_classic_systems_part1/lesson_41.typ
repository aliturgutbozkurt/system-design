#import "/template.typ": *

#show: doc => setup_book(title: "Ders 41: Bildirim Sistemi (Notification Service) Tasarımı: Öncelik Kuyrukları ve Rate Limits", doc)

#lesson_header(
  41,
  "Bildirim Sistemi (Notification Service) Tasarımı: Öncelik Kuyrukları ve Rate Limits",
  "Designing a Notification System: Priority Queues & Rate Limits",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ BİLDİRİM SİSTEMİ MİMARİSİ ]

   [Mikroservisler] ──▶ [ API GATEWAY ] ──▶ [ NOTIFICATION SERVICE ]
                                                    │
                                                    ▼
                     ┌─────────────────────────────────────────────────────────────┐
                     │ ÖNCELİK KUYRUKLARI (PRIORITY QUEUES - KAFKA / SQS)          │
                     │ • Yüksek Öncelik (OTP / Şifre Sıfırlama SMS'i - <500ms)     │
                     │ • Düşük Öncelik  (Pazarlama & İndirim E-postaları)          │
                     └──────────────────────┬──────────────────────────────────────┘
                                            │
                                            ▼
                     ┌─────────────────────────────────────────────────────────────┐
                     │ DISPATCH WORKERS (Kullanıcı Ayarları & Rate Limit Kontrolü) │
                     │ "Kullanıcı gece 23:00'ten sonra bildirim istemiyor!"        │
                     └──────┬───────────────────────┬───────────────────────┬──────┘
                            │                       │                       │
                            ▼                       ▼                       ▼
                     [ Apple APNs ]          [ Google FCM ]          [ Twilio SMS ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir şirketin kargo ve mektup odasını düşünün: Masada iki sepet vardır. Kırmızı sepet (Yüksek Öncelik): 'Kullanıcının kredi kartı şifresi SMS'i'. Bu hemen 2 saniyede gönderilmelidir! Mavi sepet (Düşük Öncelik): 'Haftasonu indirim bülteni'. Bu 3 saat sonra gitse de kimse ölmez. Görevli çıraklar daima kırmızı sepetteki mektupları önce taşır. Ayrıca görevlinin elinde bir kural listesi vardır: 'Ahmet Bey'e günde 3'ten fazla reklam SMS'i atma, yoksa bizi mahkemeye verir!' Bildirim sistemi işte bu akıllı mektup odasıdır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Picture a corporate dispatch room with two delivery trays. The Red Tray (High Priority) holds emergency 2FA one-time passwords: these MUST land on customer phones within 3 seconds! The Blue Tray (Low Priority) holds weekly marketing coupons: whether these arrive now or at 3:00 AM doesn't matter. Couriers always empty the red tray first. The dispatcher also enforces user opt-outs: 'Never send marketing pushes after 10:00 PM, and cap marketing at 2 pushes per user per day!' That is an enterprise Notification Engine!]
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
      MAANG Seviyesi Bildirim Sistemi Mimarisi: 1) Doğrulama & Kullanıcı Tercihleri (User Preferences): Kullanıcı hangi kanalları açtı? (iOS Push, Android FCM, SMS, E-posta). Kullanıcının 'Rahatsız Etmeyin' (Do Not Disturb - DND) saatleri ve zaman dilimi (Timezone) kontrol edilir. 2) Önceliklendirme Kuyrukları (Priority Queues): OTP ve Güvenlik alarmları yüksek öncelikli Kafka topic'lerine; bültenler düşük öncelikli kuyruklara aktarılır. Düşük öncelikli yoğunluk yüksek öncelikli SMS'leri asla bloklayamaz. 3) Hız Sınırlama & Birleştirme (Rate Limiting & De-duplication): Kullanıcıya 1 saatte en fazla 1 SMS gitmesi kuralı Redis ile denetlenir. Benzer bildirimler birleştirilir (Notification Aggregation, ör. 'Ali ve 5 kişi fotoğrafını beğendi'). 4) Üçüncü Parti Sağlayıcılar: Apple APNs, Google FCM, Twilio SMS, SendGrid E-posta entegrasyonları.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG Notification System Blueprint: 1) Preference & Consent Engine: Evaluates user settings (APNs vs FCM vs Twilio SMS vs SendGrid), opt-out flags, and local timezone Do Not Disturb (DND) windows. 2) Strict Queue Isolation: Segregates critical transactional OTPs into dedicated high-priority Kafka topics, keeping them isolated from marketing campaign backlogs. 3) Frequency Capping & Aggregation: Redis counters enforce frequency caps (e.g. max 3 promotional pushes/day). Aggregation workers batch high-velocity social notifications (e.g. 'Alice and 14 others liked your post') to avoid notification fatigue. 4) Resilient Downstream Adapters: Wrap third-party gateway integrations (Twilio, APNs) in Circuit Breakers with dead-letter fallback queues.]
    ]
  )
]

#java25_box[
```java
// Java 25: Öncelikli Bildirim Yönlendirme Modeli
public class NotificationRouter {
    public enum Priority { HIGH_OTP, LOW_MARKETING }
    public record Notification(String userId, String channel, String message, Priority priority) {}

    public String routeToQueue(Notification notif) {
        return switch (notif.priority()) {
            case HIGH_OTP -> "QUEUE_CRITICAL_HIGH_SPEED (SLA < 1s)";
            case LOW_MARKETING -> "QUEUE_BULK_BATCH (SLA < 4 hours)";
        };
    }
}

void main() {
    var router = new NotificationRouter();
    var otp = new NotificationRouter.Notification("u1", "SMS", "Kodunuz: 9481", NotificationRouter.Priority.HIGH_OTP);
    var promo = new NotificationRouter.Notification("u2", "PUSH", "%50 İndirim Başladı!", NotificationRouter.Priority.LOW_MARKETING);

    IO.println("OTP Yolu:   " + router.routeToQueue(otp));
    IO.println("Promo Yolu: " + router.routeToQueue(promo));
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
      Mülakatta 'Tüm bildirimleri tek bir RabbitMQ kuyruğuna atarım' demeyin! 10 milyon kullanıcılı bir e-posta kampanyası başladığında kuyruk şişer ve banka şifresi bekleyen bir kullanıcının SMS'i 45 dakika sonra gider. Kritik OTP'ler ile pazarlama bildirimleri KESİNLİKLE ayrı kuyruklarda izole edilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Funneling all notifications into a single shared queue is an architectural catastrophe. A 5-million marketing campaign will choke the queue, delaying password reset OTPs by 30 minutes! High-priority OTPs require dedicated, isolated queue infrastructure.]
    ]
  )
]

#takeaways_box((
    ("Kritik OTP ve güvenlik bildirimleri pazarlama kuyruklarından tamamen izole edilir.", "Isolate transactional OTP alerts from marketing campaigns into dedicated queues."),
    ("Kullanıcı tercihleri, zaman dilimi ve DND saatleri bildirim fırlatılmadan önce denetlenir.", "Filter notifications against user opt-outs, timezones, and frequency caps before dispatch."),
    ("Benzer bildirimler (Aggregation) birleştirilerek kullanıcının spam hissetmesi engellenir.", "Notification aggregation batches high-frequency interactions into clean digests."),
))
