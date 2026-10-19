#import "/template.typ": *

#show: doc => setup_book(title: "Ders 7: DNS ve Coğrafi Yönlendirme: Anycast, Geo-DNS ve Latency-Based Routing", doc)

#lesson_header(
  7,
  "DNS ve Coğrafi Yönlendirme: Anycast, Geo-DNS ve Latency-Based Routing",
  "DNS & Geo-Routing: Anycast, GeoDNS & Latency Routing",
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways"
)

#diagram_box[
```text
   [ KULLANICI (İSTANBUL) ]                   [ KULLANICI (TOKYO) ]
              │                                          │
              ▼                                          ▼
   ┌──────────────────────┐                   ┌──────────────────────┐
   │ Anycast DNS Sorgusu  │                   │ Anycast DNS Sorgusu  │
   │ (IP: 198.51.100.1)   │                   │ (IP: 198.51.100.1)   │
   └──────────┬───────────┘                   └──────────┬───────────┘
              │ BGP Routing                              │ BGP Routing
              ▼                                          ▼
   ┌──────────────────────┐                   ┌──────────────────────┐
   │ Frankfurt PoP / Edge │                   │ Tokyo PoP / Edge     │
   │ (Gecikme: 25ms)      │                   │ (Gecikme: 8ms)       │
   └──────────────────────┘                   └──────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Dünyanın neresinde olursanız olun acil ambulans çağırmak için tek bir numara (örneğin 112) çevirirsiniz. Ama İstanbul'dan aradığınızda telefonunuz Tokyo'daki hastaneye değil, sokağınızın başındaki istasyona bağlanır! İşte `Anycast DNS` tam olarak budur: Bütün dünyaya tek bir IP adresi ilan edersiniz (BGP yönlendirme ile); internet yönlendiricileri kullanıcının isteğini ona ışık hızıyla en yakın olan veri merkezine teslim eder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[No matter what neighborhood you live in, dialing an emergency number routes you to the closest ambulance garage, not one across the Pacific Ocean! That is `Anycast BGP Routing`. Multiple servers across the globe announce the exact same IP address. Autonomous internet routers automatically steer a user's packets along the shortest physical BGP path to their nearest edge Point of Presence (PoP)!]
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
      Geleneksel Unicast mimarisinde her sunucu tekil bir IP adresine sahiptir. Anycast'te ise dünyanın dört bir yanındaki onlarca veri merkezi BGP (Border Gateway Protocol) üzerinden aynı IP bloğunu anons eder. İstemci DNS sorgusu attığında en yakın PoP (Point of Presence) yanıt verir. Geo-DNS ise istemcinin IP adresine bakarak coğrafi konuma özel farklı IP'ler döner (örneğin ABD kullanıcısına us-east, Avrupa kullanıcısına eu-west IP'si). Latency-Based Routing ise AWS Route 53 gibi sistemlerin küresel ağ gecikmelerini sürekli ölçerek en düşük RTT sunan bölgeye yönlendirmesidir.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Unicast binds an IP address uniquely to one machine. In Anycast, distributed PoPs globally announce identical IP prefixes via BGP. Routers forward packets toward the topologically nearest network hop. GeoDNS inspects client recursive resolver IPs to synthesize geographically tailored responses. Latency-Based Routing (e.g. AWS Route 53) continuously probes edge-to-region RTTs to resolve DNS to the lowest-latency origin datacenter.]
    ]
  )
]

#java25_box[
```java
// Java 25: Simüle Edilmiş Coğrafi DNS Çözümleyici (GeoDNS Resolver)
import java.util.Map;

public record GeoDnsResolver(Map<String, String> regionDatacenters, String defaultDatacenter) {
    public String resolveTargetIp(String clientCountryCode) {
        return regionDatacenters.getOrDefault(clientCountryCode, defaultDatacenter);
    }
}

void main() {
    var geoDns = new GeoDnsResolver(Map.of(
        "TR", "195.175.25.10 (Frankfurt Edge)",
        "JP", "210.140.10.20 (Tokyo Edge)",
        "US", "198.51.100.5 (Virginia Edge)"
    ), "198.51.100.5 (Default US-East)");

    IO.println("Türkiye'den gelen istek -> " + geoDns.resolveTargetIp("TR"));
    IO.println("Japonya'dan gelen istek -> " + geoDns.resolveTargetIp("JP"));
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
      DNS tabanlı yönlendirmede DNS önbellekleme (TTL - Time To Live) riskini unutmayın! TTL 300 saniye (5 dakika) ise, bir veri merkezi çöktüğünde kullanıcıların DNS önbelleği 5 dakika boyunca ölü sunucuya gitmeye devam eder. Bu yüzden DNS tek başına anlık failover için yetersizdir; önüne Anycast IP konmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[DNS TTL caching delays failover! If TTL is 300 seconds, clients continue sending traffic to a crashed datacenter for up to 5 minutes. Never rely solely on DNS for sub-second failover; front it with Anycast BGP routing.]
    ]
  )
]

#takeaways_box((
    ("Anycast, DDoS saldırılarını küresel PoP noktalarına dağıtarak soğurur.", "Anycast absorbs multi-terabit DDoS traffic by dispersing packets across dozens of edge PoPs."),
    ("Geo-DNS ve Latency-Based Routing kullanıcıyı fiziksel olarak en yakın merkeze bağlar.", "GeoDNS and latency routing minimize round-trip times by binding users to adjacent regions."),
    ("Düşük TTL failover süresini kısaltır ancak kök DNS sunucularına binen sorgu yükünü artırır.", "Lowering DNS TTL accelerates disaster failover at the expense of higher DNS query load."),
))
