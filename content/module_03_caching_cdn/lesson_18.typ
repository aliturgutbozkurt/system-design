#import "/template.typ": *

#show: doc => setup_book(title: "Ders 18: CDN (Content Delivery Network) ve Kenar Hesaplama (Edge Computing & PoP)", doc)

#lesson_header(
  18,
  "CDN (Content Delivery Network) ve Kenar Hesaplama (Edge Computing & PoP)",
  "CDNs & Edge Computing: PoPs, Anycast & Edge Workers",
  "Önbellekleme Mimarisi ve CDN Stratejileri",
  "Distributed Caching Architectures & CDN Strategies"
)

#diagram_box[
```text
   [ KULLANICI (İSTANBUL) ]                   [ KULLANICI (SYDNEY) ]
              │                                          │
              ▼ (<10ms Gecikme)                          ▼ (<10ms Gecikme)
   ┌──────────────────────┐                   ┌──────────────────────┐
   │ İstanbul CDN PoP     │                   │ Sydney CDN PoP       │
   │ (Görseller, JS, CSS) │                   │ (Görseller, JS, CSS) │
   └──────────┬───────────┘                   └──────────┬───────────┘
              │                                          │
              │ Cache MISS veya Dinamik İstek            │ Cache MISS
              ▼                                          ▼
   ┌─────────────────────────────────────────────────────────────────┐
   │ MERKEZİ ORİJİN SUNUCUSU (ORIGIN SERVER - FRANKFURT AWS REGION)  │
   └─────────────────────────────────────────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Netflix'teki 4K bir filmi izlemek için her seferinde Kaliforniya'daki ana sunucuya bağlanıp okyanusun altındaki kabloları ısıtmak zorunda kalsaydınız film donardı! Bunun yerine Netflix, o filmin kopyalarını mahallenizdeki internet servis sağlayıcısının (ISP) içine yerleştirilmiş özel kutulara (CDN PoP - Point of Presence) koyar. Siz filmi izlerken Kaliforniya'dan değil, 5 kilometre ötenizdeki kutudan çekersiniz. CDN işte bu küresel film ve fotoğraf kütüphanesidir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[If streaming a 4K movie on Netflix required pulling bytes directly from an origin database in Los Angeles over trans-oceanic cables, video would buffer endlessly! Instead, Netflix pre-stages encrypted copies of popular media into custom appliances (Open Connect CDN PoPs) embedded directly inside your city's local ISP exchange. You stream from 5 miles away, not 7,000 miles across the ocean! That is a Content Delivery Network (CDN)!]
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
      CDN (İçerik Dağıtım Ağı), dünya genelinde yüzlerce Point of Presence (PoP) noktasında çalışan ters proxy sunucuları ağıdır. 1) Statik İçerik Hızlandırma: Resimler, videolar, JS/CSS dosyaları origin'e gitmeden kenarda sunulur. Origin bant genişliği tüketimini %80-%95 azaltır. 2) Dinamik İçerik Hızlandırma: Dinamik API istekleri önbelleğe alınamasa bile, istemci ile PoP arasındaki TCP/TLS el sıkışması yerel tamamlanır ve origin ile PoP arasında açık tutulan optimize BGP tünelleri (Route Optimization) üzerinden akıtılır. 3) Edge Computing (Cloudflare Workers, AWS Lambda\@Edge): JWT doğrulama, A/B testi, bot koruması ve coğrafi yönlendirme kodları doğrudan kenar sunucularda (Edge) çalıştırılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[A Content Delivery Network (CDN) is a globally distributed mesh of caching proxies deployed across hundreds of edge Points of Presence (PoPs). 1) Static Acceleration: Serves media, images, CSS, and binaries locally, offloading 90%+ of origin egress costs. 2) Dynamic Site Acceleration (DSA): Even uncacheable dynamic API payloads accelerate via early TLS handshakes at the edge PoP, traversing persistent, route-optimized BGP backbones to origin. 3) Edge Compute (Cloudflare Workers, Fastly Compute): Executes lightweight serverless logic (JWT validation, A/B routing, geolocation geofencing, bot mitigation) directly at edge nodes within 5ms of clients.]
    ]
  )
]

#java25_box[
```java
// Java 25: CDN Cache-Control Başlık Üreticisi ve Edge Karar Motoru
public record CdnPolicy(int maxAgeSeconds, int sharedMaxAgeSeconds, boolean isPublic) {
    public String toHeaderValue() {
        return (isPublic ? "public, " : "private, ") 
            + "max-age=" + maxAgeSeconds 
            + ", s-maxage=" + sharedMaxAgeSeconds // s-maxage CDN için geçerlidir!
            + ", stale-while-revalidate=60";
    }
}

void main() {
    // Statik Profil Resmi Politikası: Tarayıcı 1 saat, CDN 24 saat önbelleğe alsın
    var avatarPolicy = new CdnPolicy(3600, 86400, true);
    IO.println("Cache-Control Başlığı: " + avatarPolicy.toHeaderValue());
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
      Mülakatta 'CDN sadece statik resimler içindir' demeyin! Modern CDN'ler (Cloudflare, Fastly, CloudFront); WAF (Web Application Firewall), DDoS kalkanı, TLS sonlandırma, dinamik rota hızlandırma ve Edge Compute (Sunucusuz kod çalıştırma) yapar.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never dismiss CDNs as simple image repositories. Modern edge networks handle DDoS scrubbing, WAF inspection, TLS termination, dynamic route optimization, and edge compute execution.]
    ]
  )
]

#takeaways_box((
    ("CDN statik içerikleri kullanıcıya en yakın PoP noktasından milisaniyeler içinde sunar.", "CDNs deliver static assets from local PoPs with sub-10ms round-trip latencies."),
    ("Origin sunucusuna binen bant genişliği ve sunucu maliyetini %90'a varan oranda düşürür.", "Edge caching shields origin infrastructures, cutting egress transit bills by up to 90%."),
    ("Edge Workers ile kimlik kontrolü ve yönlendirme mantığı istemciye en yakın noktada yürütülür.", "Edge computing offloads perimeter authentication and traffic routing directly to the network fringe."),
))
