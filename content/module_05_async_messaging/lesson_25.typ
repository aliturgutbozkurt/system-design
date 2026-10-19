#import "/template.typ": *

#show: doc => setup_book(title: "Ders 25: Senkron vs Asenkron İletişim: Zamansal Ayrışma (Temporal Decoupling)", doc)

#lesson_header(
  25,
  "Senkron vs Asenkron İletişim: Zamansal Ayrışma (Temporal Decoupling)",
  "Synchronous vs Asynchronous: Temporal Decoupling & Buffering",
  "Asenkron İletişim, Mesajlaşma ve Olay Tabanlı Mimari",
  "Asynchronous Messaging & Event-Driven Architecture"
)

#diagram_box[
```text
   [ SENKRON REST ÇAĞRISI - ZİNCİRLEME ÇÖKÜŞ TEHLİKESİ (CASCADING FAILURE) ]
   [İstemci] ──▶ [Order Service] ──▶ [Payment Service] ──▶ [Inventory Service]
   (Herkes birbirini bloke ederek bekler! Biri yavaşlarsa tüm zincir donar!)

   [ ASENKRON MESAJLAŞMA - ZAMANSAL AYRIŞMA (TEMPORAL DECOUPLING) ]
   [İstemci] ──▶ [Order Service] ──▶ [ MESAJ KUYRUĞU / KAFKA ]
                      │                      │              │
                      ▼ "202 Kabul Edildi"   ▼              ▼
                    (50ms)           [Payment Worker]  [Inventory Worker]
                                     (Kendi hızında tüketir; biri ölse bile kuyruk saklar!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Senkron iletişim, arkadaşınızın evine gidip kapısını çalmak ve kapıyı açana kadar karda kışta 2 saat kapının önünde dikilmektir; arkadaşınız evde yoksa işiniz mahvolur! Asenkron iletişim ise hediyeyi arkadaşınızın posta kutusuna (Mesaj Kuyruğu) bırakıp yolunuza devam etmektir. Arkadaşınız isterse 3 saat sonra, isterse ertesi gün eve gelsin; mektubu kutudan alır ve okur. Sistemlerinizin birbirinin ayakta olmasına bağımlı olmadan çalışması (Zamansal Ayrışma) işte bu posta kutusu sayesindedir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Synchronous communication is ringing your friend's doorbell and standing frozen in a blizzard for 2 hours waiting for them to open up; if they aren't home, you freeze to death! Asynchronous communication is dropping a parcel into their locked mailbox (Message Queue) and going about your business. Whether your friend gets home in 10 minutes or tomorrow morning, the parcel sits safe in the mailbox. Decoupling services in time (Temporal Decoupling) ensures no service halts waiting for another!]
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
      Senkron (HTTP REST, gRPC) iletişimde çağıran servis yanıt gelene kadar bir işletim sistemi iş parçacığını (thread) ve soketini bloke eder. Dağıtık mimarilerde A -> B -> C -> D şeklindeki senkron çağrı zincirleri 'Cascading Failure' (zincirleme çöküş) yaratır; D servisi 5 saniye gecikirse A'nın tüm thread havuzu tükenir. Asenkron iletişim (Message Queues) zamansal ayrışma (Temporal Decoupling) sağlar: 1) İstemci isteği kuyruğa atıp anında 'HTTP 202 Accepted' alır. 2) Kuyruk bir tampon (Shock Absorber) görevi görerek ani trafik patlamalarını emer. 3) Tüketici servisler çökseler bile yeniden başladıklarında kuyrukta biriken mesajları kaldıkları yerden işlemeye devam eder.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Synchronous invocations (REST, gRPC) hold operating system threads and network sockets hostage until upstream downstream services respond. In deep call chains (A -> B -> C -> D), a latency spike in service D exhausts thread pools across all upstream hosts, triggering catastrophic cascading outages. Asynchronous messaging decouples producers and consumers temporally: 1) Producers publish to durable message brokers and return HTTP 202 immediately. 2) Queues act as shock absorbers buffering flash traffic spikes. 3) Downstream worker failure causes zero data loss; consumers catch up monotonically upon restart.]
    ]
  )
]

#java25_box[
```java
// Java 25: Asenkron İş Kuyruğu ve İşçi Modeli (Virtual Threads Destekli)
import java.util.concurrent.*;

public class AsyncJobQueue {
    public record OrderJob(String orderId, double amount, long timestamp) {}

    private final BlockingQueue<OrderJob> queue = new LinkedBlockingQueue<>(1000);

    public boolean publishJob(OrderJob job) {
        return queue.offer(job); // Kuyruk dolmadığı sürece bloke etmeden at
    }

    public void startWorker() {
        Thread.ofVirtual().start(() -> {
            while (true) {
                try {
                    OrderJob job = queue.take(); // Mesaj gelene kadar bekle
                    IO.println("İşlendi: Sipariş #" + job.orderId() + ", Tutar: $" + job.amount());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });
    }
}

void main() throws InterruptedException {
    var jobQueue = new AsyncJobQueue();
    jobQueue.startWorker();

    jobQueue.publishJob(new AsyncJobQueue.OrderJob("ORD_991", 149.99, System.currentTimeMillis()));
    Thread.sleep(50); // Sanal iş parçacığının işlemesini bekle
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
      Asenkron mimarinin bedeli 'Eventual Consistency' (Nihai Tutarlılık) ve karmaşık hata yönetimidir. Kullanıcıya 'Siparişiniz alındı, hazırlanıyor' mesajı vermeniz gerekir; kullanıcı anında faturasını göremeyebilir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[The trade-off of asynchronous messaging is eventual consistency and complex failure compensation. The UI must adapt to an asynchronous workflow ('Your order is processing') rather than assuming instantaneous transactional guarantees.]
    ]
  )
]

#takeaways_box((
    ("Asenkron iletişim servisler arasındaki zamansal ve mekansal bağımlılığı koparır.", "Asynchronous communication eliminates temporal and spatial coupling across services."),
    ("Mesaj aracıları ani trafik dalgalanmalarında doğal bir amortisör (shock absorber) görevi görür.", "Message queues act as elastic buffers absorbing sudden traffic spikes without dropping requests."),
    ("Senkron çağrı zincirleri yerine asenkron olaylar kullanmak zincirleme çöküşleri engeller.", "Replacing synchronous call chains with asynchronous queues prevents cascading system outages."),
))
