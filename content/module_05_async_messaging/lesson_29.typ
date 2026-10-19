#import "/template.typ": *

#show: doc => setup_book(title: "Ders 29: Idempotency (Tekrarlanabilirlik): Ağ Yeniden Denemelerinde Mükerrerliği Önleme", doc)

#lesson_header(
  29,
  "Idempotency (Tekrarlanabilirlik): Ağ Yeniden Denemelerinde Mükerrerliği Önleme",
  "Idempotency Patterns: Preventing Double Charges & Duplicates",
  "Asenkron İletişim, Mesajlaşma ve Olay Tabanlı Mimari",
  "Asynchronous Messaging & Event-Driven Architecture"
)

#diagram_box[
```text
   [ KREDİ KARTI ÇEKİMİNDE IDEMPOTENCY KEY AKIŞI ]
   İstemci                          API Gateway / Servis                  Redis / DB
      │                                       │                                │
      ├──1. POST /charge (Key: "tx_abc123")──▶│                                │
      │                                       ├──2. SETNX "tx_abc123" PENDING─▶│ (Kilit Alındı!)
      │                                       ├──3. Bankadan Para Çek ($50)    │
      │                                       ├──4. UPDATE "tx_abc123" SUCCESS▶│
      │◀──5. Ağ Koptu! (Timeout Hatası!)──────┤                                │
      │                                       │                                │
      ├──6. Tekrar Dene (Key: "tx_abc123")───▶│                                │
      │                                       ├──7. GET "tx_abc123" ──────────▶│ (Kayıt Var: SUCCESS!)
      │◀──8. 200 OK (Para tekrar çekilmedi!)──┤                                │
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Asansör çağrı düğmesini düşünün: Düğmeye bir kez basarsanız ışığı yanar ve asansör kata doğru hareket eder. Sabırsızlanıp düğmeye 10 kez daha basarsanız ne olur? Asansör 10 kat daha hızlı gelmez, 10 tane ayrı asansör de çağrılmaz! Düğmeye 1 kez basmakla 100 kez basmak aynı sonucu üretir. İşte matematikte ve yazılımda buna `Idempotent` (Tekrarlanabilir) denir: Kullanıcı interneti koptu diye 'Öde' butonuna 5 kez tıklasa bile kredi kartından sadece 1 kez 50 TL çekilmelidir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Think of an elevator call button: Pressing it once illuminates the light and dispatches the cab. If you impatiently mash the button 10 more times, does it arrive 10 times faster? Does it spawn 10 separate elevators? No! Pressing it once or 100 times yields the exact same state. That is `Idempotency`. If a customer's phone switches from Wi-Fi to 5G during checkout and re-submits a payment 5 times, their credit card must be charged exactly once!]
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
      Dağıtık sistemlerde ağ zaman aşımları (Timeout) nedeniyle istemciler istekleri yeniden dener (Retry). Bir POST isteği doğası gereği idempotent değildir. Çözüm: 1) İstemci Tarafında Benzersiz Anahtar (Idempotency Key): İstemci isteği göndermeden önce bir UUID üretir (`Idempotency-Key: 9b1deb4d...`) ve HTTP başlığına ekler. 2) Dağıtık Kilit & Durum Tablosu (Redis / DB): API Gateway anahtarı alır; `SET key PENDING NX EX 120` ile atomik kilit oluşturur. İşlem tamamlandığında sonuç (Response Body) bu anahtarın altına kaydedilir. 3) Mükerrer İstek Geldiğinde: Eğer anahtar `SUCCESS` durumundaysa, işlem tekrar çalıştırılmaz; önbellekteki ilk başarılı yanıt aynen geri dönülür.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[In distributed microservices, network timeouts inevitably trigger client retries. While GET and PUT are inherently idempotent, HTTP POST mutations are not. Enterprise Idempotency Pattern: 1) Client Idempotency Key: The client generates a unique UUID (`Idempotency-Key: 9b1deb4d...`) passed in headers. 2) Atomic State Locking: The receiver executes an atomic lock (`SET key PENDING NX EX 60`) in Redis or an RDBMS unique table constraint. 3) Response Caching: When the transactional operation succeeds, the final response payload is persisted against the idempotency key. Subsequent retry attempts detect the existing key and return the cached receipt immediately without re-executing side effects.]
    ]
  )
]

#java25_box[
```java
// Java 25: Idempotency Key Motoru (Ödeme Güvenlik Kalkanı)
import java.util.concurrent.*;

public class PaymentIdempotencyEngine {
    public enum TxStatus { PENDING, COMPLETED }
    public record TxRecord(TxStatus status, String responsePayload) {}

    private final ConcurrentMap<String, TxRecord> store = new ConcurrentHashMap<>();

    public synchronized String processPayment(String idempotencyKey, double amount) {
        TxRecord existing = store.get(idempotencyKey);
        if (existing != null) {
            if (existing.status() == TxStatus.COMPLETED) {
                IO.println("⚡ Önbellekteki Makbuz Döndü: " + existing.responsePayload());
                return existing.responsePayload();
            }
            throw new IllegalStateException("İşlem şu anda başka bir thread tarafından yürütülüyor!");
        }

        // 1. Durumu PENDING yap
        store.put(idempotencyKey, new TxRecord(TxStatus.PENDING, null));

        // 2. Banka POS simülasyonu
        IO.println(">>> Bankadan $" + amount + " çekildi! (Kart İşlemi Yapıldı)");
        String receipt = "RECEIPT_TX_" + System.currentTimeMillis();

        // 3. Durumu COMPLETED yap ve sonucu sakla
        store.put(idempotencyKey, new TxRecord(TxStatus.COMPLETED, receipt));
        return receipt;
    }
}

void main() {
    var engine = new PaymentIdempotencyEngine();
    String key = "req_uuid_550e8400";

    // 1. İstek (Başarılı)
    engine.processPayment(key, 100.0);
    // 2. Ağ hatası nedeniyle aynı isteğin tekrarı (Tekrar para çekilmez!)
    engine.processPayment(key, 100.0);
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
      Idempotency anahtarlarını veritabanında sonsuza kadar saklamayın! Bu tablolar milyonlarca gereksiz anahtarla şişer. Idempotency anahtarlarına 24 veya 48 saatlik bir TTL (Time-To-Live) belirleyin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Do not persist idempotency keys indefinitely. Storing transient keys permanently bloats storage. Enforce a rolling 24-to-48 hour TTL window, which easily exceeds maximum client retry horizons.]
    ]
  )
]

#takeaways_box((
    ("Idempotency Key, ağ hatalarında mükerrer para çekilmesini ve kayıt açılmasını engeller.", "Idempotency keys eliminate double-billing and duplicate resource creation during retries."),
    ("HTTP POST istekleri istemcinin ürettiği benzersiz bir token ile idempotent kılınır.", "Pairing client-generated UUID tokens with atomic server-side state locks ensures idempotency."),
    ("Stripe, PayPal ve Adyen gibi ödeme devlerinin tüm API'leri bu desenle korunur.", "Industry payment APIs (Stripe, Adyen) mandate Idempotency-Key headers on all mutations."),
))
