#import "/template.typ": *

#show: doc => setup_book(title: "Ders 8: Yük Dengeleyiciler (L4 vs L7): TCP vs HTTP, NGINX, HAProxy, AWS ALB", doc)

#lesson_header(
  8,
  "Yük Dengeleyiciler (L4 vs L7): TCP vs HTTP, NGINX, HAProxy, AWS ALB",
  "Load Balancers (L4 vs L7): TCP vs HTTP, NGINX, HAProxy, AWS ALB",
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways"
)

#diagram_box[
```text
   [ İSTEMCİ TRAFİĞİ ]
            │
            ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ LAYER 4 (L4) LOAD BALANCER (Transport Katmanı - IP + TCP/UDP Portu)    │
   │ Paket içeriğine (URL, Cookie, JSON) bakmaz! Ultra Hızlı (Milyonlarca   │
   │ bağlantı/sn). Örnek: Linux IPVS, AWS NLB, F5 Big-IP                    │
   └───────────────────────────────────┬────────────────────────────────────┘
                                       │ TCP Akışı
                                       ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ LAYER 7 (L7) LOAD BALANCER (Uygulama Katmanı - HTTP, Headers, Cookies) │
   │ Paket içeriğini çözer: "/api/video" -> Video Pod, "/api/pay" -> Pay Pod│
   │ SSL Sonlandırma, Akıllı Yönlendirme. Örnek: NGINX, HAProxy, Envoy, ALB │
   └───────────────────┬────────────────────────────────┬───────────────────┘
                       │                                │
                       ▼                                ▼
              [ Video Servisleri ]             [ Ödeme Servisleri ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      L4 ve L7 yük dengeleyiciyi bir postanenin iki farklı görevlisi gibi hayal edin: L4 görevlisi, sadece zarfın üzerindeki sokak numarasına bakar (IP ve Port). Zarfın içini ASLA açmaz; paketi gözü kapalı ışık hızında doğru binaya fırlatır! L7 görevlisi ise zarfı açar, içindeki mektubu okur (HTTP URL'i, Cookie, Başlıklar). 'Aaa bu bir fatura ödemesiymiş, bunu muhasebe masasına götüreyim; bu bir video talebiymiş, bunu sinema salonuna göndereyim' der. L4 süper hızlıdır, L7 ise süper zekidir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Think of L4 and L7 load balancers as two mail sorting clerks: The L4 clerk only glances at the building address on the outside envelope (IP and TCP Port). They NEVER open the envelope; they fling packets at blistering wire speed! The L7 clerk tears the envelope open, reads the letter (HTTP Headers, Cookies, URL paths), and decides: 'This letter says /video, send it to the media cluster; this says /checkout, route to the payment gateway.' L4 offers raw throughput; L7 delivers smart content routing!]
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
      OSI 4. Katman (L4), Taşıma katmanında (TCP/UDP) çalışır. NAT (Network Address Translation) veya DSR (Direct Server Return) kullanır. HTTP paketini çözmediği (SSL terminasyonu yapmadığı) için CPU maliyeti çok düşüktür; saniyede milyonlarca eşzamanlı TCP bağlantısını yönetebilir. OSI 7. Katman (L7), Uygulama katmanında çalışır. TLS/SSL el sıkışmasını sonlandırır (SSL Termination), HTTP istek başlıklarını, URI yolunu (`/users` vs `/orders`), JWT tokenlarını ve Cookie oturumlarını inceler. Bu sayede mikroservis yönlendirmesi, A/B testi ve rate limiting yapabilir; ancak CPU ve bellek maliyeti daha yüksektir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Layer 4 (L4) operates on TCP/UDP transport segments using NAT or Direct Server Return (DSR). Because it avoids terminating TLS or parsing HTTP buffers, L4 introduces microsecond latency and scales to tens of millions of concurrent connections (AWS NLB, Maglev). Layer 7 (L7) operates on application-level HTTP/HTTPS semantics. It terminates TLS, parses headers, inspects cookies, and routes requests based on URI paths (`/stream` vs `/auth`). L7 enables canary routing, sticky sessions, and rate limiting at higher CPU overhead.]
    ]
  )
]

#java25_box[
```java
// Java 25: L7 İçerik Tabanlı Yönlendirme Simülasyonu (Path-Based Routing)
public class Layer7Router {
    public record HttpRequest(String path, String method, String clientIp) {}

    public String routeRequest(HttpRequest req) {
        // Java 25 Pattern Matching ile L7 URL Yönlendirmesi:
        return switch (req.path()) {
            case String p when p.startsWith("/api/v1/auth")     -> "AUTH_SERVICE_CLUSTER";
            case String p when p.startsWith("/api/v1/payments") -> "PAYMENT_PCI_CLUSTER";
            case String p when p.startsWith("/static/")         -> "CDN_S3_STORAGE";
            default                                             -> "CORE_BACKEND_CLUSTER";
        };
    }
}

void main() {
    var router = new Layer7Router();
    var payReq = new Layer7Router.HttpRequest("/api/v1/payments/charge", "POST", "10.0.0.1");
    IO.println("İstek Hedefi: " + router.routeRequest(payReq));
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
      Mülakatta 'Tüm trafiği doğrudan tek bir NGINX L7 load balancer'a bağlarım' demeyin! Yüksek ölçekte (milyonlarca QPS) mimari standart şöyledir: Anycast DNS -> L4 Load Balancer (AWS NLB / Maglev) -> L7 Load Balancer Filosu (NGINX / Envoy) -> Mikroservisler.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never funnel millions of raw internet connections directly into a single L7 NGINX node. The enterprise standard is a two-tier hierarchy: Anycast DNS -> L4 NLB cluster -> Fleet of autoscaled L7 Envoy/NGINX proxies.]
    ]
  )
]

#takeaways_box((
    ("L4 paket içeriğine bakmaz, ultra yüksek verim (throughput) ve düşük gecikme sunar.", "L4 routes on IP:Port tuples, offering extreme connection throughput and sub-millisecond latencies."),
    ("L7 HTTP başlıklarına ve URL'e göre akıllı mikroservis yönlendirmesi yapar.", "L7 inspects HTTP/gRPC semantics for intelligent path-based and header-based routing."),
    ("Modern mimarilerde L4 önde donanım kalkanı, L7 arkada uygulama beyni olarak birlikte kullanılır.", "Two-tier load balancing places L4 at the edge fronting a dynamic fleet of L7 proxies."),
))
