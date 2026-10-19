#import "/template.typ": *

#show: doc => setup_book(
  title: "Aptala Anlatır Gibi MAANG Sistem Tasarımı El Kitabı",
  author: "Antigravity & MAANG Architecture Guild",
  doc
)

#book_front_cover()

#pagebreak()
#v(20pt)
#align(center)[
  #text(size: 20pt, weight: "bold", fill: rgb("0f172a"))[Önsöz ve Başlarken / Preface & Getting Started]
]
#v(16pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,
  [
    == 🇹🇷 Bu Eğitim Hakkında
    Bu kitap; Meta, Amazon, Apple, Netflix, Google (MAANG) ve benzeri birinci sınıf teknoloji şirketlerinin Sistem Tasarımı (System Design) mülakatlarına hazırlanan yazılım mühendisleri ve mimarlar için özel olarak hazırlanmıştır.

    En karmaşık dağıtık sistem mimarileri (Consistent Hashing, LSM-Trees, Raft Consensus, Kafka Partitions, Gorilla TSDB, H3 Uber Geohashing, Snowflake IDs, Saga Pattern vb.) *bir aptala anlatır gibi* en yalın analojiler, mimari ASCII akış şemaları ve modern *Java 25 (Loom, Virtual Threads, Records, IO)* kodlarıyla ele alınmıştır.

    60 derslik bu müfredat, sizi junior bir geliştiriciden milyonlarca eşzamanlı isteği ve petabaytlarca veriyi sakinlikle yöneten bir *Staff+ Principal Architect* zihniyetine ulaştırmayı hedefler.
  ],
  [
    == 🇬🇧 About This Masterclass
    This masterclass is meticulously engineered for software engineers, tech leads, and aspiring architects preparing for high-stakes System Design rounds at Tier-1 companies (MAANG / FAANG).

    We demystify high-concurrency distributed systems—ranging from Consistent Hashing and Raft Consensus to Kafka Event Streams, TSDB compression, and Geo-distributed Ledgers—using crystal-clear *Explain Like I'm 5 (ELI5)* metaphors, architectural schematics, and clean *Java 25* implementations (featuring Project Loom Virtual Threads, pattern matching, and concise records).

    Over 60 progressive lessons grouped into 10 structured modules, this curriculum transforms abstract theoretical knowledge into decisive Staff+ architectural leadership.
  ]
)

#v(20pt)
#line(length: 100%, stroke: 0.8pt + rgb("e2e8f0"))
#v(10pt)

#outline(
  title: [İçindekiler / Table of Contents],
  depth: 2,
  indent: auto
)

#pagebreak()

#module_cover(
  1,
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework",
  "MAANG mülakatlarında başarılı olmanın 4 adımlı altın çerçevesi, dikey/yatay ölçekleme, P99 gecikme metrikleri, SLA/SLO ve CAP/PACELC teoremleri.",
  "The 4-step MAANG interview blueprint, vertical vs horizontal scaling, tail latencies (P99), high availability math (SLA 9s), and CAP/PACELC trade-offs."
)

#include "/content/module_01_fundamentals/lesson_01.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_02.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_03.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_04.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_05.typ"
#v(14pt)

#include "/content/module_01_fundamentals/lesson_06.typ"
#v(14pt)


#module_cover(
  2,
  "Yük Dengeleme, Ağ Protokolleri ve API Ağ Geçitleri",
  "Load Balancing, Networking Protocols & API Gateways",
  "Trafiği akıllıca yönlendirme sanatı: Anycast DNS, L4 vs L7 Load Balancer, gRPC vs WebSockets, API Gateway deseni ve Dağıtık Rate Limiting algoritmaları.",
  "The art of traffic routing: Anycast DNS, Layer 4 vs Layer 7 load balancing, gRPC vs WebSockets, API Gateway patterns, and Distributed Rate Limiting algorithms."
)

#include "/content/module_02_load_balancing/lesson_07.typ"
#v(14pt)

#include "/content/module_02_load_balancing/lesson_08.typ"
#v(14pt)

#include "/content/module_02_load_balancing/lesson_09.typ"
#v(14pt)

#include "/content/module_02_load_balancing/lesson_10.typ"
#v(14pt)

#include "/content/module_02_load_balancing/lesson_11.typ"
#v(14pt)

#include "/content/module_02_load_balancing/lesson_12.typ"
#v(14pt)


#module_cover(
  3,
  "Önbellekleme Mimarisi ve CDN Stratejileri",
  "Distributed Caching Architectures & CDN Strategies",
  "Donanım gecikme piramidi, Cache-Aside vs Write-Through, LRU tahliye mekanizması, Redis Cluster, Cache Stampede/Avalanche felaketleri ve Kenar CDN mimarisi.",
  "Hardware latency hierarchy, Cache-Aside vs Write-Through, LRU evictions, Redis clustering, Thundering Herd mitigations, and Edge CDN deployment topologies."
)

#include "/content/module_03_caching_cdn/lesson_13.typ"
#v(14pt)

#include "/content/module_03_caching_cdn/lesson_14.typ"
#v(14pt)

#include "/content/module_03_caching_cdn/lesson_15.typ"
#v(14pt)

#include "/content/module_03_caching_cdn/lesson_16.typ"
#v(14pt)

#include "/content/module_03_caching_cdn/lesson_17.typ"
#v(14pt)

#include "/content/module_03_caching_cdn/lesson_18.typ"
#v(14pt)


#module_cover(
  4,
  "Veritabanı Mimarisi, Bölümleme ve Replikasyon",
  "Database Architecture, Sharding & Replication Topologies",
  "SQL vs NoSQL seçim matrisi, NoSQL türleri, Single/Multi-Leader replikasyon, Sharding stratejileri, Consistent Hashing ve B-Tree vs LSM-Tree indeksleme motorları.",
  "SQL vs NoSQL trade-offs, NoSQL families, Quorum replication, Sharding topologies, Consistent Hashing rings, and B-Tree vs LSM-Tree storage engines."
)

#include "/content/module_04_databases_sharding/lesson_19.typ"
#v(14pt)

#include "/content/module_04_databases_sharding/lesson_20.typ"
#v(14pt)

#include "/content/module_04_databases_sharding/lesson_21.typ"
#v(14pt)

#include "/content/module_04_databases_sharding/lesson_22.typ"
#v(14pt)

#include "/content/module_04_databases_sharding/lesson_23.typ"
#v(14pt)

#include "/content/module_04_databases_sharding/lesson_24.typ"
#v(14pt)


#module_cover(
  5,
  "Asenkron İletişim, Mesajlaşma ve Olay Tabanlı Mimari",
  "Asynchronous Messaging & Event-Driven Architecture",
  "Zamansal ayrışma, RabbitMQ vs Apache Kafka, Kafka partition ve consumer grupları, Exactly-Once garantileri, Idempotency ve Transactional Outbox deseni.",
  "Temporal decoupling, RabbitMQ vs Apache Kafka, Kafka commit logs & consumer groups, Exactly-Once semantics, Idempotency tokens, and the Transactional Outbox pattern."
)

#include "/content/module_05_async_messaging/lesson_25.typ"
#v(14pt)

#include "/content/module_05_async_messaging/lesson_26.typ"
#v(14pt)

#include "/content/module_05_async_messaging/lesson_27.typ"
#v(14pt)

#include "/content/module_05_async_messaging/lesson_28.typ"
#v(14pt)

#include "/content/module_05_async_messaging/lesson_29.typ"
#v(14pt)

#include "/content/module_05_async_messaging/lesson_30.typ"
#v(14pt)


#module_cover(
  6,
  "Dağıtık Sistem Temelleri ve Eşgüdüm",
  "Distributed Systems Fundamentals, Consensus & Coordination",
  "Saat kaymaları ve Vektör Saatleri, Raft fikir birliği algoritması, etcd/ZooKeeper kilitleri, Twitter Snowflake ID üreteci, Saga deseni ve Circuit Breaker.",
  "Clock drift & Vector Clocks, Raft consensus mechanics, etcd/ZooKeeper coordination, Twitter Snowflake ID generators, Saga vs 2PC, and Circuit Breaker resilience."
)

#include "/content/module_06_distributed_systems/lesson_31.typ"
#v(14pt)

#include "/content/module_06_distributed_systems/lesson_32.typ"
#v(14pt)

#include "/content/module_06_distributed_systems/lesson_33.typ"
#v(14pt)

#include "/content/module_06_distributed_systems/lesson_34.typ"
#v(14pt)

#include "/content/module_06_distributed_systems/lesson_35.typ"
#v(14pt)

#include "/content/module_06_distributed_systems/lesson_36.typ"
#v(14pt)


#module_cover(
  7,
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1",
  "TinyURL (Base62), Pastebin (S3 + TTL), Dağıtık Rate Limiter (Redis Lua), Web Crawler (URL Frontier), Bildirim Servisi ve Proximity/Yelp (Geohash vs QuadTree).",
  "TinyURL (Base62 encoding), Pastebin (S3 + TTL), Distributed Rate Limiter (Redis Lua), Web Crawler (URL Frontier), Notification System, and Yelp Proximity (Geohash vs QuadTree)."
)

#include "/content/module_07_classic_systems_part1/lesson_37.typ"
#v(14pt)

#include "/content/module_07_classic_systems_part1/lesson_38.typ"
#v(14pt)

#include "/content/module_07_classic_systems_part1/lesson_39.typ"
#v(14pt)

#include "/content/module_07_classic_systems_part1/lesson_40.typ"
#v(14pt)

#include "/content/module_07_classic_systems_part1/lesson_41.typ"
#v(14pt)

#include "/content/module_07_classic_systems_part1/lesson_42.typ"
#v(14pt)


#module_cover(
  8,
  "Klasik MAANG Tasarım Problemleri - Bölüm 2",
  "Classic MAANG System Designs - Part 2",
  "WhatsApp/Slack Sohbet Sistemi, Twitter/Instagram News Feed (Fan-Out), YouTube Video Akışı (HLS/DASH), Dropbox/Drive Senkronizasyonu, Google Typeahead (Trie) ve Flaş İndirim (Ticketmaster).",
  "WhatsApp/Slack Chat (WebSockets), Twitter News Feed (Fan-Out trade-offs), YouTube Video Streaming (HLS/DASH), Dropbox File Sync (Block Chunks), Google Search Typeahead (Trie), and Ticketmaster Flash Sales."
)

#include "/content/module_08_classic_systems_part2/lesson_43.typ"
#v(14pt)

#include "/content/module_08_classic_systems_part2/lesson_44.typ"
#v(14pt)

#include "/content/module_08_classic_systems_part2/lesson_45.typ"
#v(14pt)

#include "/content/module_08_classic_systems_part2/lesson_46.typ"
#v(14pt)

#include "/content/module_08_classic_systems_part2/lesson_47.typ"
#v(14pt)

#include "/content/module_08_classic_systems_part2/lesson_48.typ"
#v(14pt)


#module_cover(
  9,
  "İleri Seviye MAANG Tasarım Problemleri",
  "Advanced MAANG Distributed System Designs",
  "Uber Yolculuk Eşleştirme (H3 Altıgenleri), Dağıtık Metrik Sistemi (TSDB), DynamoDB Klonu, Dağıtık Kuyruk (Zero-Copy), Stripe Ödeme Sistemi ve Canlı Skor Tablosu (SkipList).",
  "Uber Ride-Hailing (H3 Hexagons), Time-Series Monitoring (Prometheus TSDB), Distributed Key-Value Store (DynamoDB), Kafka Clone, Stripe Payments, and Gaming Leaderboard (SkipLists)."
)

#include "/content/module_09_advanced_systems/lesson_49.typ"
#v(14pt)

#include "/content/module_09_advanced_systems/lesson_50.typ"
#v(14pt)

#include "/content/module_09_advanced_systems/lesson_51.typ"
#v(14pt)

#include "/content/module_09_advanced_systems/lesson_52.typ"
#v(14pt)

#include "/content/module_09_advanced_systems/lesson_53.typ"
#v(14pt)

#include "/content/module_09_advanced_systems/lesson_54.typ"
#v(14pt)


#module_cover(
  10,
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook",
  "45 dakikalık mülakatı yönetme sanatı, netleştirme soruları, Zero-Trust ve mTLS güvenliği, Çok Bölgeli (Multi-Region) felaket kurtarma, FinOps bulut maliyeti ve Staff+ Büyük Kapanışı.",
  "Mastering the 45-minute whiteboard session, clarifying questions, Zero-Trust & mTLS, Active-Active Multi-Region DR, Cloud FinOps economics, and the Staff+ Architecture Finale."
)

#include "/content/module_10_interview_mastery/lesson_55.typ"
#v(14pt)

#include "/content/module_10_interview_mastery/lesson_56.typ"
#v(14pt)

#include "/content/module_10_interview_mastery/lesson_57.typ"
#v(14pt)

#include "/content/module_10_interview_mastery/lesson_58.typ"
#v(14pt)

#include "/content/module_10_interview_mastery/lesson_59.typ"
#v(14pt)

#include "/content/module_10_interview_mastery/lesson_60.typ"
#v(14pt)


#pagebreak()
#v(40pt)
#align(center)[
  #rect(fill: rgb("0f172a"), radius: 10pt, inset: (x: 24pt, y: 32pt), width: 90%)[
    #text(size: 24pt, fill: rgb("38bdf8"), weight: "bold")[🎓 TEBRİKLER! / CONGRATULATIONS!]    #v(10pt)
    #text(size: 14pt, fill: white)[60 Derslik MAANG Sistem Tasarımı Yolculuğunu Başarıyla Tamamladınız!]    #v(6pt)
    #text(size: 11pt, fill: rgb("94a3b8"))[You have successfully conquered all 60 lessons of the MAANG System Design Masterclass!]    #v(20pt)
    #line(length: 60%, stroke: 1pt + rgb("4f46e5"))
    #v(15pt)
    #text(size: 10pt, fill: rgb("cbd5e1"))[
      Architecture Schematics • Java 25 Virtual Threads • Distributed Consensus • Staff+ Trade-Offs
    ]
  ]
]
