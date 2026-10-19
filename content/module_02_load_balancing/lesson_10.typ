#import "/template.typ": *

#show: doc => setup_book(title: "Ders 10: Ağ İletişim Protokolleri: HTTP/1.1 vs HTTP/2 vs HTTP/3 QUIC, WebSockets, gRPC, SSE", doc)

#lesson_header(
  10,
  "Ağ İletişim Protokolleri: HTTP/1.1 vs HTTP/2 vs HTTP/3 QUIC, WebSockets, gRPC, SSE",
  "Network Protocols: HTTP/1.1 vs HTTP/2 vs HTTP/3, WebSockets, gRPC, SSE",
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways"
)

#diagram_box[
```text
   [ PROTOKOL EVRİMİ ]
   HTTP/1.1 : Tek TCP bağlantısında tek istek (Head-of-Line Blocking!)
   HTTP/2   : Tek TCP üzerinde Multiplexing (Binary Framing, Header Compression)
   HTTP/3   : UDP Tabanlı QUIC! (Sıfır TCP Head-of-Line, 0-RTT El Sıkışma!)

   [ İKİ YÖNLÜ vs TEK YÖNLÜ İLETİŞİM ]
   WebSockets : Tam İki Yönlü (Full-Duplex) Sürekli TCP Kanalı (Chat, Finans)
   SSE (Event): Sunucudan İstemciye Tek Yönlü Canlı Veri Akışı (Borsa, Skor)
   gRPC       : HTTP/2 Üzerinde Protobuf ile Ultra Hızlı Mikroservis İletişimi
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      HTTP/1.1 tek şeritli dar bir otoyola benzer; öndeki kamyon arıza yaparsa arkadaki 100 araba bekler (Head-of-Line Blocking). HTTP/2 bu yola 10 şerit ekler; aynı kablodan aynı anda onlarca veri akar. HTTP/3 (QUIC) ise asfaltı kaldırıp manyetik raylı trene geçmektir: TCP'nin hantal onay mekanizmalarını atar, UDP üzerinden sıfır gecikmeyle uçar! WebSockets iki kişinin telefonla kesintisiz konuşmasıdır; SSE ise televizyondaki canlı haber bültenini tek yönlü dinlemektir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[HTTP/1.1 is a single-lane mountain road: if a lumber truck stalls, all 50 cars behind it freeze (Head-of-Line Blocking). HTTP/2 widens it into a 10-lane superhighway, multiplexing dozens of concurrent streams over one TCP pipe. HTTP/3 (QUIC) throws away asphalt entirely: it swaps fragile TCP for lightning-fast UDP with zero-RTT handshakes! WebSockets is an open telephone call (full-duplex chat); Server-Sent Events (SSE) is tuning into an emergency FM radio station (unidirectional live streaming)!]
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
      1) HTTP/1.1: Metin tabanlıdır; her istek için yeni TCP veya keep-alive gerektirir. 2) HTTP/2: Binary framing katmanı getirir. Tek TCP bağlantısında stream multiplexing ve HPACK başlık sıkıştırması yapar; ancak paket kaybında TCP seviyesinde HoL blocking yaşar. 3) HTTP/3 (QUIC): Google'ın geliştirdiği UDP tabanlı protokoldür. Her akış (stream) birbirinden tamamen bağımsızdır; bir paket kaybolsa bile diğer akışlar etkilenmez. 4) gRPC: Google'ın HTTP/2 üzerinde Protocol Buffers (ikili serileştirme) kullanan, JSON'dan 7-10 kat daha hızlı ve tip güvenli RPC protokolüdür; iç mikroservis haberleşmesinin standardıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[1) HTTP/1.1: Text-oriented with head-of-line blocking. 2) HTTP/2: Binary framing layer enabling multiplexed bidirectional streams over a shared TCP connection with HPACK header compression; still suffers TCP-level HoL blocking on packet drops. 3) HTTP/3 (QUIC): Replaces TCP with UDP-based transport, eliminating multi-stream HOL blocking and slashing handshakes to 0-RTT connection resumptions across mobile cell towers. 4) gRPC: High-throughput RPC framework using HTTP/2 multiplexing and Protocol Buffers serialization; de facto industry standard for microservice-to-microservice internal transit.]
    ]
  )
]

#java25_box[
```java
// Java 25: gRPC vs REST Veri Serileştirme Karşılaştırma Modeli
// Protocol Buffers Mantığı (Java 25 Record ile Temsil Edilmiş Binary Kompakt Yapı)
public record UserProfileProto(long userId, String username, String email, int karma) {
    // JSON Boyutu: ~95 Byte  |  Protobuf İkili Boyutu: ~28 Byte (3.4 kat daha küçük!)
    public byte[] toMockProtobufBytes() {
        // İkili serileştirme simülasyonu: Ağ trafiğini ve serileştirme CPU yükünü minimize eder
        return ("B:" + userId + ":" + karma).getBytes();
    }
}

void main() {
    var user = new UserProfileProto(1049281L, "aliturgut", "ali@example.com", 942);
    IO.println("Simüle Protobuf Boyutu: " + user.toMockProtobufBytes().length + " bytes");
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
      Mülakatta 'İç mikroservisler arasında da JSON REST kullanırım' demeyin. Dış dünyadan istemciler için JSON REST uygundur; ancak iç mikroservisler arasında yüksek verim, düşük CPU tüketimi ve tip güvenliği için gRPC (Protobuf) tercih edilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Don't default to JSON REST across internal microservices. Use REST at the perimeter API Gateway, but standardize on gRPC over HTTP/2 internally for compact binary footprints and code-generated contracts.]
    ]
  )
]

#takeaways_box((
    ("HTTP/3 QUIC mobil cihazların baz istasyonu değişiminde bile bağlantıyı koparmaz.", "HTTP/3 QUIC connection IDs migrate seamlessly across Wi-Fi and cellular switches without dropping."),
    ("gRPC ikili Protocol Buffers formatı ile JSON'a kıyasla ağ ve CPU tasarrufu sağlar.", "gRPC cuts payload serialization overhead by up to 70% compared to verbose JSON strings."),
    ("Canlı iki yönlü sohbet için WebSockets, tek yönlü canlı akışlar için SSE tercih edilir.", "Use WebSockets for bidirectional duplex streams (chat) and SSE for server pushes (tickers)."),
))
