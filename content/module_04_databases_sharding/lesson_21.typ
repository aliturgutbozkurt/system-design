#import "/template.typ": *

#show: doc => setup_book(title: "Ders 21: Veritabanı Replikasyonu: Single-Leader, Multi-Leader ve Quorum (R + W > N)", doc)

#lesson_header(
  21,
  "Veritabanı Replikasyonu: Single-Leader, Multi-Leader ve Quorum (R + W > N)",
  "Replication Topologies: Single-Leader, Multi-Leader & Quorum (R+W > N)",
  "Veritabanı Mimarisi, Bölümleme ve Replikasyon",
  "Database Architecture, Sharding & Replication Topologies"
)

#diagram_box[
```text
   [ 1. SINGLE-LEADER (Master-Slave) ]        [ 2. QUORUM LEADERLESS (R + W > N) ]
             [ LEADER (Master) ]                        N = 3 Düğüm
              Yazmalar buraya!                          W = 2 (En az 2 düğüm onaylamalı)
             ┌───────┴───────┐                          R = 2 (En az 2 düğümden okunmalı)
             │ Asenkron      │ Asenkron
             ▼               ▼                         ┌────────┐ ┌────────┐ ┌────────┐
        [Follower 1]    [Follower 2]                   │ Node 1 │ │ Node 2 │ │ Node 3 │
        (Sadece Oku)    (Sadece Oku)                   └────────┘ └────────┘ └────────┘
                                                       R + W = 4 > 3 -> En az 1 düğüm
                                                       kesinlikle en güncel veriyi içerir!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Single-Leader replikasyon, sınıfta tek bir öğretmenin (Leader/Master) konuşması ve 30 öğrencinin (Followers/Replicas) öğretmeni defterine kopyalaması gibidir. Herkes soru sorup okuyabilir (Okuma ölçeklenir), ama tahtaya sadece öğretmen yazar. Öğretmen bayılırsa öğrencilerden biri yeni öğretmen seçilir (Failover). Quorum (Lidersiz) ise 3 kişilik bir jüri heyetidir: Bir kararın geçerli olması için en az 2 üyenin 'Evet' demesi (Write Quorum: W=2) ve okurken en az 2 üyeye danışılması (Read Quorum: R=2) şarttır. İki çoğunluk kümesi mutlaka en az 1 kişide kesişeceği için doğru bilgi asla kaybolmaz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Single-Leader replication is a lecture hall where only the professor (Leader/Master) speaks and 30 students (Followers/Replicas) transcribe notes into their notebooks. Anyone can read, but only the professor writes. If the professor faints, a student is elected the new professor (Failover). Leaderless Quorum (Dynamo/Cassandra) is a 3-judge jury: to confirm a fact, at least 2 judges must sign off (W=2), and to read, at least 2 judges must be polled (R=2). Because two majorities mathematically overlap, you are guaranteed to read the latest truth!]
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
      1) Single-Leader (Primary-Secondary): Tüm yazmalar Leader düğüme gider; Leader değişiklikleri replikasyon logu (WAL) ile follower'lara asenkron veya yarı-senkron aktarır. Okuma trafiği follower'lara dağıtılarak ölçeklenir; ancak 'Replication Lag' (gecikme) nedeniyle 'Kendi Yazdığını Okuyamama' (Read-Your-Own-Writes) sorunu oluşabilir. 2) Multi-Leader: Birden fazla veri merkezinde yazma kabul edilir; ancak eşzamanlı çakışmalar (Write Conflicts) çözülmelidir (Last-Write-Wins veya CRDT). 3) Leaderless (Dynamo-Style Quorum): Lider yoktur; istemci doğrudan N düğüme yazar ve okur. Quorum Kuralı: \$R + W > N\$. Eğer 3 replikalı bir kümede \$W=2\$ ve \$R=2\$ ise, okunan 2 düğümden en az biri en son yazmayı görmüş olmak zorundadır (Version Vector ile en günceli seçilir).
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[1) Single-Leader (Active-Passive): Writes direct strictly to the leader, streaming mutations via Write-Ahead Logs (WAL) to read-replicas. Horizontally scales read bandwidth, but asynchronous replication introduces replication lag and stale reads (mitigated via read-your-own-writes session sticky routing to leader). 2) Multi-Leader (Active-Active): Multiple datacenters accept local writes, requiring conflict resolution strategies like Last-Write-Wins (clock-skew sensitive) or CRDTs. 3) Leaderless Quorum (Amazon Dynamo, Cassandra): Clients coordinate writes across N nodes. The Quorum Equation: \$R + W > N\$. If N=3, W=2, and R=2, the read set and write set must overlap by at least one node, guaranteeing strong consistency via read-repair or hinted handoff.]
    ]
  )
]

#java25_box[
```java
// Java 25: Quorum Okuma ve 'En Güncel Versiyonu' Seçme Motoru
import java.util.List;

public class QuorumReadCoordinator {
    public record VersionedValue(String value, long versionTimestamp) {}

    public VersionedValue resolveQuorumRead(List<VersionedValue> responses) {
        // En yüksek zaman damgasına sahip veriyi seç (Last-Write-Wins)
        return responses.stream()
                .max((a, b) -> Long.compare(a.versionTimestamp(), b.versionTimestamp()))
                .orElseThrow();
    }
}

void main() {
    var coordinator = new QuorumReadCoordinator();
    // 3 Düğümden okunan 2 cevap (R=2):
    var node1 = new QuorumReadCoordinator.VersionedValue("User: Ali Bozkurt (Eski)", 1000L);
    var node2 = new QuorumReadCoordinator.VersionedValue("User: Ali Turgut Bozkurt (Yeni)", 1005L);

    var resolved = coordinator.resolveQuorumRead(List.of(node1, node2));
    IO.println("Quorum Çözümlenen Değer: " + resolved.value() + " [Versiyon: " + resolved.versionTimestamp() + "]");
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
      Asenkron replikasyonda 'Leader çöktüğünde veri kaybolmaz' demeyin! Asenkron replikasyonda Leader'a yazılan ancak henüz Follower'a iletilmeyen son işlemler Leader çökerse sonsuza kadar buharlaşır (Data Loss). Mülakatta yarı-senkron replikasyon veya Raft konsensüsü alternatiflerini tartışın.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[In asynchronous replication, if the leader crashes before WAL packets arrive at replicas, committed writes are permanently lost. Explicitly call out this failover data loss window and present semi-synchronous replication or Raft consensus as hardening options.]
    ]
  )
]

#takeaways_box((
    ("Single-Leader okuma ağırlıklı sistemlerde okumayı follower'lara yayarak ölçekler.", "Single-Leader topologies scale read-heavy workloads across fleets of replicas."),
    ("R + W > N quorum formülü lidersiz sistemlerde güçlü tutarlılık sağlar.", "The quorum condition R + W > N ensures read and write sets overlap on at least one fresh node."),
    ("Replication Lag, kullanıcının kendi yaptığı güncellemeyi hemen görememesine yol açabilir.", "Replication lag causes stale read anomalies unless read-after-write consistency is enforced."),
))
