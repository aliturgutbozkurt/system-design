# 📐 Aptala Anlatır Gibi MAANG Sistem Tasarımı El Kitabı
### Explain Like I'm 5: MAANG / FAANG System Design Interview Masterclass

> **60 Ders • 10 Bölüm • Mimari ASCII Şemalar • Java 25 (Loom & Records) • Çift Dilli (🇹🇷 Türkçe & 🇬🇧 English)**  
> *Sıfırdan Meta, Amazon, Apple, Netflix, Google (MAANG) ve Tier-1 şirketlerin Sistem Tasarımı mülakatlarında Staff+ Principal Architect seviyesine yükselin.*

---

## 🌟 Proje Özeti / Project Overview

Bu proje; en karmaşık yüksek ölçekli dağıtık sistem mimarilerini (Consistent Hashing, LSM-Trees, Raft Consensus, Kafka Event Streams, Uber H3 Hexagonal Grid, Twitter Snowflake, Stripe Double-Entry Ledger vb.) **bir aptala anlatır gibi (ELI5)** en yalın benzetmeler, mimari akış şemaları ve modern **Java 25** kodlarıyla öğreten kapsamlı bir başucu eseridir.

- **71 Adet Yayın Kalitesinde PDF:** 60 tekil ders PDF'i, 10 modül paketi ve 261 sayfalık master mega-kitap (`System_Design_MAANG_ELI5.pdf`).
- **Modern Web Companion Reader:** Anlık arama (Live Search), çift dil görünümü (Türkçe / İngilizce / Yan Yana) ve internet bağlantısı olmadan (`file://`) doğrudan tarayıcıda çalışan web arayüzü.
- **Java 25 Modern Kod Örnekleri:** Project Loom sanal iş parçacıkları (Virtual Threads), `record` veri modelleri, modern `switch` örüntü eşleme ve `IO.println` sözdizimi.

---

## 📚 10 Bölüm ve 60 Derslik Müfredat Haritası

| Bölüm | Konu Başlığı (TR) | Topic (EN) | Dersler |
|---|---|---|---|
| **Bölüm 01** | Temel İlkeler, Ölçeklenebilirlik & MAANG Çerçevesi | Core Fundamentals, Scalability & MAANG Framework | Ders 1 - 6 |
| **Bölüm 02** | Yük Dengeleme, Trafik Yönlendirme & Hız Sınırlama | Load Balancing, Traffic Routing & Rate Limiting | Ders 7 - 12 |
| **Bölüm 03** | Önbellek Stratejileri, Dağıtık Bellek & CDN | Caching Strategies, Distributed In-Memory & CDN | Ders 13 - 18 |
| **Bölüm 04** | Veritabanı Mimarileri, Sharding & Consistent Hashing | Database Engines, Sharding & Consistent Hashing | Ders 19 - 24 |
| **Bölüm 05** | Asenkron Mesajlaşma, Event-Driven & Kafka | Asynchronous Messaging, Event Streams & Kafka | Ders 25 - 30 |
| **Bölüm 06** | Dağıtık Sistemler: Uzlaşma, Saatler & Dayanıklılık | Distributed Systems: Consensus, Clocks & Resilience | Ders 31 - 36 |
| **Bölüm 07** | Klasik MAANG Mülakat Sistemleri - Kısım 1 | Classic MAANG Interview Systems - Part 1 | Ders 37 - 42 |
| **Bölüm 08** | Klasik MAANG Mülakat Sistemleri - Kısım 2 | Classic MAANG Interview Systems - Part 2 | Ders 43 - 48 |
| **Bölüm 09** | İleri Düzey & Gerçek Dünya Yüksek Ölçek Sistemleri | Advanced Production Scale Distributed Systems | Ders 49 - 54 |
| **Bölüm 10** | MAANG Mülakat Ustalığı: Staff+ Liderlik & Trade-Offs | MAANG Interview Mastery: Staff+ Leadership | Ders 55 - 60 |

---

## 🗂️ Detaylı Ders Listesi

<details>
<summary><b>Tüm 60 Dersi Görmek İçin Tıklayın / Click to expand all 60 Lessons</b></summary>

- **Bölüm 1: Temel İlkeler ve Mülakat Çerçevesi**
  - **Ders 1:** 4 Adımlı MAANG Mülakat Çerçevesi (RADAR Metodu)
  - **Ders 2:** Dikey vs Yatay Ölçekleme & Donanım Sınırları
  - **Ders 3:** Gecikme Hiyerarşisi & P99 Yanılgısı
  - **Ders 4:** Yüksek Erişilebilirlik ve 9'lar Kuralı (SLA / SLO)
  - **Ders 5:** CAP ve PACELC Teoremleri
  - **Ders 6:** Mülakatçı Gibi Zihinden Hesaplama (Back-of-the-Envelope)
- **Bölüm 2: Yük Dengeleme ve API Yönetimi**
  - **Ders 7:** DNS, Anycast Yönlendirme ve GeoDNS
  - **Ders 8:** L4 vs L7 Load Balancer
  - **Ders 9:** Yük Dengeleme Algoritmaları
  - **Ders 10:** HTTP/1.1 vs HTTP/2 vs HTTP/3 (QUIC) ve gRPC
  - **Ders 11:** API Gateway Mimarisi (BFF)
  - **Ders 12:** Dağıtık Hız Sınırlayıcı (Rate Limiter)
- **Bölüm 3: Caching ve CDN**
  - **Ders 13:** Bellek Hiyerarşisi ve Önbellek Katmanı
  - **Ders 14:** Caching Stratejileri (Cache-Aside, Write-Through, Write-Behind)
  - **Ders 15:** Önbellek Boşaltma İlkeleri (LRU, LFU, FIFO)
  - **Ders 16:** Dağıtık Redis Kümesi ve Hash Slots (16384)
  - **Ders 17:** Önbellek Felaketleri (Stampede, Avalanche, Penetration)
  - **Ders 18:** CDN (İçerik Dağıtım Ağı) ve Edge Computing
- **Bölüm 4: Veritabanları ve Sharding**
  - **Ders 19:** SQL vs NoSQL Karar Matrisi
  - **Ders 20:** NoSQL Türleri (Key-Value, Document, Column, Graph)
  - **Ders 21:** Veritabanı Çoğaltma ve Quorum Consensus (R + W > N)
  - **Ders 22:** Veritabanı Bölümleme (Range vs Hash Sharding)
  - **Ders 23:** Consistent Hashing ve Sanal Düğümler (Virtual Nodes)
  - **Ders 24:** LSM-Tree vs B-Tree İndeks Mimarisi
- **Bölüm 5: Asenkron İletişim ve Kafka**
  - **Ders 25:** Senkron vs Asenkron İletişim & Zamansal Ayrışma
  - **Ders 26:** Mesaj Kuyruğu vs Event Stream (RabbitMQ vs Kafka)
  - **Ders 27:** Apache Kafka Mimarisi: Partitions, Offsets & Commit Log
  - **Ders 28:** Mesaj İletim Garantileri (At-least-once, Exactly-once)
  - **Ders 29:** Idempotency Keys ve Mükerrer İşlem Engelleme
  - **Ders 30:** Transactional Outbox Pattern ve Debezium CDC
- **Bölüm 6: Dağıtık Sistemler ve Uzlaşma**
  - **Ders 31:** Saat Kayması (Clock Drift) ve Vektör Saatleri (Vector Clocks)
  - **Ders 32:** Dağıtık Uzlaşma (Consensus) ve Raft Algoritması
  - **Ders 33:** Dağıtık Kilit Yönetimi (Distributed Locks - etcd / ZooKeeper)
  - **Ders 34:** Dağıtık Benzersiz ID Üretimi (Twitter Snowflake)
  - **Ders 35:** İki Fazlı Taahhüt (2PC) vs Dağıtık Saga Deseni
  - **Ders 36:** Dağıtık Hata Toleransı: Circuit Breaker & Exponential Backoff
- **Bölüm 7: Klasik Sistemler - Bölüm 1**
  - **Ders 37:** TinyURL (URL Kısaltma Servisi)
  - **Ders 38:** Pastebin / Gist (Metin Depolama Servisi)
  - **Ders 39:** Dağıtık Rate Limiter (API Sınırlandırma Servisi)
  - **Ders 40:** Web Crawler (Arama Motoru Örümceği)
  - **Ders 41:** Dağıtık Bildirim Servisi (Apple APNs / Google FCM)
  - **Ders 42:** Yakındaki Yerleri Bulma (Yelp / Google Maps - Geohash)
- **Bölüm 8: Klasik Sistemler - Bölüm 2**
  - **Ders 43:** WhatsApp / Telegram (Milyar Kullanıcılı Sohbet)
  - **Ders 44:** Twitter / X News Feed (Zaman Tüneli Mimarisi)
  - **Ders 45:** YouTube / Netflix Video Akış ve Kod Dönüştürme
  - **Ders 46:** Google Drive / Dropbox Dosya Senkronizasyonu
  - **Ders 47:** Google Search Typeahead / Autocomplete
  - **Ders 48:** Flash Sale ve Bilet Satış Sistemi (Ticketmaster)
- **Bölüm 9: İleri Seviye Sistemler**
  - **Ders 49:** Uber / Grab Sürücü-Yolcu Eşleştirme (H3 Spatial)
  - **Ders 50:** Dağıtık Metrik ve İzleme Sistemi (Prometheus / Gorilla TSDB)
  - **Ders 51:** Dağıtık Anahtar-Değer Deposu (Amazon DynamoDB)
  - **Ders 52:** Sıfır Kopyalamalı Mesaj Kuyruğu (Zero-Copy sendfile)
  - **Ders 53:** Dağıtık Ödeme Ağ Geçidi ve Çift Taraflı Muhasebe (Stripe)
  - **Ders 54:** Gerçek Zamanlı Oyun Liderlik Tablosu (SkipList & Redis ZSET)
- **Bölüm 10: Mülakat Ustalığı ve Staff+ Seviye**
  - **Ders 55:** 45 Dakikalık Mülakatın Zaman Yönetimi ve İletişim
  - **Ders 56:** Muğlaklıkla Başa Çıkma ve Soru Sorma Sanatı
  - **Ders 57:** Sıfır Güven (Zero-Trust), mTLS ve Veri Güvenliği
  - **Ders 58:** Çok Bölgeli Felaket Kurtarma (Active-Active Multi-Region)
  - **Ders 59:** Maliyet Optimizasyonu (FinOps) ve Bulut Faturaları
  - **Ders 60:** Staff+ Seviye Mülakat Değerlendirme Kriterleri (Rubric)

</details>

---

## 🚀 Hızlı Başlangıç / Quickstart

### 1. Web Companion Reader'ı Başlatma
Herhangi bir kurulum gerektirmeden, doğrudan `web/index.html` dosyasını tarayıcınızda açabilir veya yerel sunucu ile çalıştırabilirsiniz:

```bash
# Python ile yerel sunucu başlatma
cd /Users/aliturgutbozkurt/Desktop/system-design
python3 -m http.server 4595
```
Tarayıcınızda açın: `http://localhost:4595/web/index.html`

### 2. PDF'leri Yeniden Derleme (Typst)
Tüm PDF belgeleri [Typst](https://typst.app) motoru ile derlenir:

```bash
# Tüm 71 PDF'i tek seferde derleme:
python3 build_all.py --all

# Sadece 261 sayfalık master kitabı derleme:
python3 build_all.py --book

# Sadece 10 bölüm paketini derleme:
python3 build_all.py --modules
```

### 3. Çalıştırılabilir Java 25 Kod Örnekleri
`examples/` dizinindeki modern Java 25 uygulamalarını doğrudan çalıştırın:

```bash
# Token Bucket Rate Limiter
java --enable-preview examples/TokenBucketRateLimiter.java

# Consistent Hash Ring (Vnodes)
java --enable-preview examples/ConsistentHashRing.java

# Twitter Snowflake 64-bit ID Üretici
java --enable-preview examples/SnowflakeIdGenerator.java

# O(1) LRU Cache
java --enable-preview examples/LruCache.java
```

---

## 📦 Çıktı Dizini Yapısı (`output/`)

```text
output/
├── book/
│   └── System_Design_MAANG_ELI5.pdf          (261 Sayfa • 2.6 MB Master Kitap)
├── modules/
│   ├── module_01_module_01_fundamentals.pdf
│   ├── module_02_module_02_load_balancing.pdf
│   ├── module_03_module_03_caching_cdn.pdf
│   ├── module_04_module_04_databases_sharding.pdf
│   ├── module_05_module_05_async_messaging.pdf
│   ├── module_06_module_06_distributed_systems.pdf
│   ├── module_07_module_07_classic_systems_part1.pdf
│   ├── module_08_module_08_classic_systems_part2.pdf
│   ├── module_09_module_09_advanced_systems.pdf
│   └── module_10_module_10_interview_mastery.pdf
└── individual/
    ├── lesson_01.pdf
    ├── lesson_02.pdf
    ...
    └── lesson_60.pdf                          (60 Adet Tekil Ders PDF'i)
```

---

## 🎨 Mimari ve Tasarım Prensipleri

1. **ELI5 (Aptala Anlatım):** Karmaşık algoritmalar hayatın içinden eğlenceli ve akılda kalıcı benzetmelerle aktarılır.
2. **MAANG-Level Deep Dive:** Kurumsal ölçekte P99 gecikmeler, cross-slot kısıtları, partition stratejileri ve donanım sınırları incelenir.
3. **Görsel Şemalar:** Her derste verinin client'tan veritabanına akışını gösteren ASCII / Unicode mimari akış kutuları yer alır.
4. **Modern Java 25:** Thread başına bellek tasarrufu sağlayan Virtual Threads (Project Loom), immutable Records ve modern desenler kullanılır.
5. **Staff+ Bakış Açısı:** Her derste mülakatçı tuzakları, darboğazlar ve altın çıkarımlar (Trade-offs) vurgulanır.

---
*Created with ❤️ by Antigravity AI for Software Engineers & System Architects.*
