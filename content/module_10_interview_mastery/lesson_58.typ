#import "/template.typ": *

#show: doc => setup_book(title: "Ders 58: Felaket Kurtarma ve Çok Bölgeli Mimari: Active-Active vs Active-Passive", doc)

#lesson_header(
  58,
  "Felaket Kurtarma ve Çok Bölgeli Mimari: Active-Active vs Active-Passive",
  "Disaster Recovery & Multi-Region: Active-Active vs Active-Passive",
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook"
)

#diagram_box[
```text
   [ 1. ACTIVE-PASSIVE (Korumalı / Hot Standby) ]
   Kullanıcılar ──▶ [ Region 1 (Aktif - Frankfurt) ] ──Asenkron Sync──▶ [ Region 2 (Pasif - İrlanda) ]
   (Bölge 1 çökerse DNS Region 2'ye yönlendirilir. RPO: ~5 dk veri kaybı, RTO: ~10 dk kesinti)

   [ 2. ACTIVE-ACTIVE (Çok Bölgeli Canlı - Multi-Region Active) ]
   Avrupa Kullanıcıları ──▶ [ Region 1 (Frankfurt) ] ◀──┐
                                                         ├── Çift Yönlü Eşleme (Bi-directional Sync)
   Asya Kullanıcıları   ──▶ [ Region 2 (Singapur)  ] ◀──┘
   (İki bölge de aynı anda canlıdır! Biri çökerse sıfır kesintiyle diğeri karşılar!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Felaket kurtarma modellerini iki farklı araba lastiği gibi düşünün: 1) Active-Passive: Arabanın bagajındaki yedek lastiktir (Stepne). Bagajda hazır bekler; yoldaki lastik patlarsa arabayı durdurur, krikoyu kaldırır, stepneyi takarsınız (15 dakika vakit kaybedersiniz - RTO). 2) Active-Active: 8 tekerlekli dev bir maden kamyonudur! 8 tekerleğin hepsi aynı anda döner. Tekerleklerden biri patlasa bile kamyon durmaz, hızını hiç kesmeden yoluna devam eder! Ancak 8 tekerleğin de aynı hızda dönmesini sağlamak (Veri senkronizasyonu) çok daha büyük bir mühendislik ister!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Compare disaster recovery to vehicular resilience: 1) Active-Passive is carrying a spare tire in your car trunk. It sits idle. When your front tire blows out, you must pull over, hoist the jack, and bolt on the spare (15 minutes of downtime - RTO). 2) Active-Active is an 8-wheeled military assault vehicle: All 8 wheels drive concurrently. If tire #3 gets shot out by a landmine, the vehicle doesn't stop for a single second; it barrels forward uninterrupted! However, keeping all 8 wheels synchronized across diverse terrain (bi-directional cross-region replication) requires supreme engineering discipline!]
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
      MAANG Felaket Kurtarma (Disaster Recovery - DR) Metrikleri ve Modelleri: 1) İki Kritik Metrik: A) RPO (Recovery Point Objective): Felaket anında kabul edilebilir maksimum veri kaybı süresi (ör. 'Son 1 dakikalık veri kaybolabilir'). B) RTO (Recovery Time Objective): Sistemin ayağa kalkması için izin verilen maksimum kesinti süresi (ör. 'Sistem 5 dakikada geri dönmeli'). 2) Active-Passive (Warm/Hot Standby): Trafik tek bir ana bölgeye (Primary) akar; veriler ikincil bölgeye (Secondary) asenkron replike edilir. Maliyeti düşüktür ancak failover sırasında RPO > 0 ve RTO gecikmesi yaşanır. 3) Multi-Region Active-Active: Her iki bölge de canlı trafik alır. Avantajı: Sıfır RTO (biri çökerse Anycast DNS veya Global Accelerator trafiği anında diğer bölgeye aktarır). Zorluğu: Çift yönlü veritabanı replikasyonu (Multi-Master / CockroachDB / Spanner) ve çakışma çözümü (Conflict Resolution: CRDTs).
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Disaster Recovery Frameworks & Metrics: 1) RPO (Recovery Point Objective): The maximum tolerable temporal window of data loss measured in time (e.g. RPO = 5 seconds means mutations older than 5s are safely preserved). 2) RTO (Recovery Time Objective): The maximum permissible duration the system can remain offline before restoration (e.g. RTO = 2 minutes). 3) Active-Passive Topology: Primary region serves 100% of traffic, streaming snapshots and WAL logs to a secondary warm standby. Cost-effective, but failover requires DNS propagation delays and risks data loss on inflight replication buffers. 4) Multi-Region Active-Active: Multiple geographic regions simultaneously ingest live traffic. Traffic fails over seamlessly with zero RTO via Anycast BGP shifts. The engineering hurdle: cross-datacenter multi-master write conflict resolution, solved via Conflict-Free Replicated Data Types (CRDTs) or globally coordinated consensus databases (Google Cloud Spanner, CockroachDB).]
    ]
  )
]

#java25_box[
```java
// Java 25: RPO ve RTO Felaket Kurtarma Hedef Modeli
public record DisasterRecoveryPlan(
    String strategyName,
    int rpoSeconds,
    int rtoSeconds,
    boolean supportsZeroDowntimeFailover
) {
    public void printDrProfile() {
        IO.println("Strateji:        " + strategyName);
        IO.println("Maks Veri Kaybı: " + rpoSeconds + " saniye (RPO)");
        IO.println("Maks Kesinti:    " + rtoSeconds + " saniye (RTO)");
        IO.println("Sıfır Kesinti:   " + supportsZeroDowntimeFailover);
    }
}

void main() {
    var activePassive = new DisasterRecoveryPlan("Active-Passive Hot Standby", 60, 300, false);
    var activeActive = new DisasterRecoveryPlan("Active-Active Multi-Region", 0, 0, true);

    IO.println("--- Active-Passive Profili ---");
    activePassive.printDrProfile();
    IO.println("\n--- Active-Active Profili ---");
    activeActive.printDrProfile();
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
      Mülakatta hemen 'Active-Active kurarım' demeyin! Çok bölgeli Active-Active mimari korkunç derecede pahalıdır ve iki bölge arasında ışık hızı gecikmesi yüzünden veri çakışmaları (Write Conflicts) çıkar. Mülakatçıya önce maliyet/fayda analizini yapıp kritiklik seviyesine göre Active-Passive veya Active-Active önereceğinizi belirtin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never jump immediately to Multi-Region Active-Active without acknowledging costs. Cross-region data egress fees, distributed locking latency, and split-brain risks can multiply operating budgets by 5x. Always balance RPO/RTO business value against cost.]
    ]
  )
]

#takeaways_box((
    ("RPO izin verilen veri kaybı süresini, RTO ise sistemin geri dönme süresini belirtir.", "RPO bounds tolerable data loss in seconds; RTO defines maximum acceptable downtime."),
    ("Active-Passive daha ucuz ve basittir ancak failover sırasında kısa bir kesinti yaşatır.", "Active-Passive minimizes infrastructure costs while accepting brief failover lag."),
    ("Active-Active sıfır kesinti (Zero RTO) sağlar ancak çift yönlü veri çakışması yönetimi gerektirir.", "Active-Active delivers instantaneous failover at the cost of cross-region write synchronization."),
))
