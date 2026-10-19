#import "/template.typ": *

#show: doc => setup_book(title: "Ders 11: API Gateway Deseni: Kimlik Doğrulama, SSL Sonlandırma ve Protokol Dönüşümü", doc)

#lesson_header(
  11,
  "API Gateway Deseni: Kimlik Doğrulama, SSL Sonlandırma ve Protokol Dönüşümü",
  "The API Gateway Pattern: Auth, SSL Termination & Protocol Translation",
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways"
)

#diagram_box[
```text
   [ MOBİL / WEB İSTEMCİLERİ ] (HTTPS / JSON / Public API)
                │
                ▼
   ┌────────────────────────────────────────────────────────────────────────┐
   │ API GATEWAY (Kong, KrakenD, Envoy, AWS API Gateway)                    │
   │ 1. SSL/TLS Sonlandırma (İç ağda yükü hafifletir)                       │
   │ 2. JWT & OAuth2 Kimlik Doğrulama / Yetkilendirme                       │
   │ 3. Hız Sınırlama (Rate Limiting) & IP Whitelisting                     │
   │ 4. Protokol Dönüşümü (Dışarıya JSON REST, İçeriye gRPC)                │
   └──────────┬─────────────────────────────┬───────────────────────────────┘
              │ gRPC                        │ gRPC
              ▼                             ▼
     [ Kullanıcı Servisi ]         [ Sipariş Servisi ]
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir ülkeye girerken sınır kapısındaki devasa pasaport kontrol binasını düşünün. Ülkedeki 100 farklı şehre gitmek isteyen her turist önce o tek kapıdan geçer: Pasaport kontrol edilir (Kimlik doğrulama), vizesi var mı bakılır (Yetkilendirme), valizinde yasaklı madde var mı taranır (Rate limiting & WAF). Şehirlere geçtikten sonra kimse size her dükkanda tekrar tekrar pasaport sormaz! API Gateway işte o sınırdaki akıllı pasaport kapısıdır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Picture a nation's central border checkpoint terminal. Every foreign traveler heading to any of 50 internal cities must pass through this single customs facility: passports are verified (Authentication), visas are inspected (Authorization), and luggage is x-rayed for contraband (WAF & Rate Limiting). Once inside the country, individual shops don't re-examine your passport! The API Gateway is that secure border checkpoint!]
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
      API Gateway deseni, mikroservis mimarilerinde tek bir giriş noktası (Single Entry Point) sunar. Görevleri: 1) SSL/TLS Termination: Ağır şifre çözme işlemini üstlenir, iç ağdaki mikroservislerin CPU yükünü düşürür. 2) Kimlik Doğrulama & Yetkilendirme: Gelen JWT/OAuth2 tokenını doğrular, kullanıcı kimliğini başlığa (`X-User-Id`, `X-Roles`) koyarak iç servislere aktarır. 3) Protokol Dönüşümü: İstemciden gelen HTTP/JSON isteklerini içeride gRPC veya Protobuf formatına dönüştürür. 4) İstek Birleştirme (API Composition): Tek bir mobil ekran için 5 farklı servisten veriyi paralel çekip tek bir JSON cevabı döner.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The API Gateway serves as the centralized reverse-proxy perimeter for microservices. Core capabilities: 1) SSL/TLS Termination: Offloads cryptographic handshakes from upstream worker pods. 2) Authentication & Token Introspection: Validates JWT/OAuth2 signatures at the edge, injecting sanitized user identity headers (`X-User-Id`, `X-Tenant-Id`) downstream. 3) Protocol Translation: Ingests public HTTP/REST and translates into internal high-speed binary gRPC calls. 4) Request Aggregation (BFF - Backend for Frontend): Batches parallel calls across disparate domains to prevent mobile network chattiness.]
    ]
  )
]

#java25_box[
```java
// Java 25: API Gateway Filtre Zinciri (Pipeline Filter Pattern)
import java.util.function.Function;

public class ApiGatewayPipeline {
    public record GatewayRequest(String path, String token, String clientIp) {}
    public record GatewayContext(GatewayRequest request, String resolvedUserId, boolean authenticated) {}

    public static Function<GatewayContext, GatewayContext> authFilter() {
        return ctx -> {
            if ("secret-jwt-token".equals(ctx.request().token())) {
                return new GatewayContext(ctx.request(), "usr_9981", true);
            }
            return new GatewayContext(ctx.request(), null, false);
        };
    }

    public static Function<GatewayContext, String> router() {
        return ctx -> ctx.authenticated() 
            ? "FORWARD -> /internal" + ctx.request().path() + " [UID:" + ctx.resolvedUserId() + "]"
            : "HTTP 401 UNAUTHORIZED";
    }
}

void main() {
    var filter = ApiGatewayPipeline.authFilter().andThen(ApiGatewayPipeline.router());
    var validReq = new ApiGatewayPipeline.GatewayRequest("/orders", "secret-jwt-token", "1.2.3.4");
    IO.println(filter.apply(new ApiGatewayPipeline.GatewayContext(validReq, null, false)));
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
      API Gateway'in içine iş mantığı (Business Logic) YAZMAYIN! Gateway bir proxy'dir; fatura hesaplama veya veritabanı sorgusu gibi işler eklerseniz Gateway monolitik bir darboğaza ve tek hata noktasına (SPOF) dönüşür.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never inject core business logic into the API Gateway layer! A gateway must remain a lean transport proxy; bloating it with domain business logic creates a brittle distributed monolith bottleneck.]
    ]
  )
]

#takeaways_box((
    ("API Gateway mikroservisleri dış dünyanın karmaşıklığından ve güvenlik risklerinden izole eder.", "The API Gateway insulates internal microservices from perimeter exposure and protocol churn."),
    ("SSL sonlandırma iç mikroservislerin CPU kapasitesini iş mantığına ayırmasını sağlar.", "SSL termination offloads intensive crypto operations from backend compute instances."),
    ("Backend-for-Frontend (BFF) deseni mobil ve web istemcilerine özel optimize edilmiş gateway'ler kurar.", "BFF variants dedicate separate gateways tailored specifically to mobile versus web UI needs."),
))
