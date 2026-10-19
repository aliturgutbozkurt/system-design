#import "/template.typ": *

#show: doc => setup_book(title: "Ders 51: Dağıtık Web Önbelleği (Distributed Key-Value Store / DynamoDB Klonu)", doc)

#lesson_header(
  51,
  "Dağıtık Web Önbelleği (Distributed Key-Value Store / DynamoDB Klonu)",
  "Designing a Distributed Key-Value Store (DynamoDB Clone)",
  "İleri Seviye MAANG Tasarım Problemleri",
  "Advanced MAANG Distributed System Designs"
)

#diagram_box[
```text
   [ AMAZON DYNAMO DÖNÜM NOKTASI MİMARİSİ (THE DYNAMO PAPER) ]

   1. Veri Bölümleme : Tutarlı Karışıklık Halkası (Consistent Hash Ring + Vnodes)
   2. Yüksek Yazma   : Sloppy Quorum & Hinted Handoff (Düğüm ölse bile komşuya yaz!)
   3. Çakışma Çözümü : Vektör Saatleri (Vector Clocks) & İstemci Çözümlemesi
   4. Arka Plan Onarım: Merkle Trees & Anti-Entropy (Arka planda sessizce eşitleme)
   5. Düğüm Keşfi    : Gossip Protocol (Dedikodu Protokolü ile merkeziyetsiz sağlık kontrolü)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Amazon Dynamo, dünyanın en sağlam kargo ağı gibidir: Amazon'un kuralı şudur: 'Müşteri sepetine ürün eklerken sistem ASLA hata vermeyecek!' Bir düğüm arıza yapsa bile paket hemen yanındaki komşu düğüme emanet edilir (Sloppy Quorum & Hinted Handoff). Arızalı düğüm kendine geldiğinde emanetçi düğüm 'Bu paket senindi, buyur al' der. İki şube arasında anlaşmazlık çıkarsa Vektör Saatleri devreye girer. Sunucular aralarında fısıldaşarak (Gossip Protocol) kimin ayakta olduğunu birbirine haber verir. Tamamen merkeziyetsiz, lideri olmayan (Leaderless) ölümsüz bir mimaridir!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Amazon Dynamo is an un-killable decentralized courier grid designed around Amazon's prime directive: 'A customer adding an item to their shopping cart must NEVER see an error screen!' If the designated server node is down, the adjacent neighbor temporarily accepts the write (Sloppy Quorum & Hinted Handoff). Once the dead node recovers, the neighbor hands the package back. If conflicting updates clash, Vector Clocks preserve causal history. Nodes continuously whisper among themselves like neighbors at a fence (Gossip Protocol) to detect cluster topology and outages without a centralized master!]
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
      Werner Vogels ve ekibinin ünlü Amazon Dynamo Paper (2007) tasarımı MAANG mülakatlarının zirvesidir: 1) Sloppy Quorum & Hinted Handoff: Yazma sırasında belirlenen N düğümden biri erişilemezse, halkadaki bir sonraki sağlıklı düğüm veriyi geçici olarak kabul eder (`hinted handoff`). Düğüm ayağa kalkınca veri asıl sahibine teslim edilir (Erişilebilirlik tavan yapar). 2) Anti-Entropy with Merkle Trees: Düğümler arasındaki veri tutarsızlıklarını tüm veriyi ağdan taşımadan bulmak için Merkle Ağaçları (Hash Trees) kullanılır; ağaçların kök hash'leri uyuşuyorsa veriler eşittir. 3) Dedikodu Protokolü (Gossip Protocol): Merkezi bir ZooKeeper/etcd olmadan düğümler rastgele seçtikleri komşularla durum bilgilerini paylaşarak küme üyeliğini merkeziyetsiz olarak (\$O(\log N)\$ sürede) senkronize eder.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The Amazon Dynamo Paper (SOSP 2007) is the magnum opus of distributed systems architecture: 1) Sloppy Quorum & Hinted Handoff: During node partitions, if healthy nodes within the primary preference list fall below quorum W, the coordinator writes to fallback nodes outside the list with a 'hint' metadata tag. Once the primary recovers, the fallback pushes the mutation home, preserving write availability above all. 2) Anti-Entropy via Merkle Trees: Replicas synchronize divergent key ranges by comparing cryptographic Merkle Tree hash roots; branches are traversed only where hashes diverge, slashing network bandwidth. 3) Gossip Protocol: Nodes execute periodic peer-to-peer heartbeat exchanges with randomly selected nodes, propagating membership and failure detector states across the cluster in \$O(\log N)\$ time without a central master coordinator.]
    ]
  )
]

#java25_box[
```java
// Java 25: Merkle Tree (Özet Ağacı) Mantığı ile Hızlı Veri Uyuşmazlığı Tespiti
import java.security.MessageDigest;

public class MerkleTreeSim {
    public static String hash(String input) {
        try {
            var md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(input.getBytes())).substring(0, 8);
        } catch (Exception e) { return ""; }
    }

    public static String computeRootHash(String dataBlockA, String dataBlockB) {
        String hashA = hash(dataBlockA);
        String hashB = hash(dataBlockB);
        // İki yaprağın hash'ini birleştirip üst düğümü oluştur:
        return hash(hashA + hashB);
    }
}

void main() {
    // İki farklı sunucudaki Merkle Kök Hash'lerini karşılaştır:
    String server1Root = MerkleTreeSim.computeRootHash("User:Ali", "Order:101");
    String server2Root = MerkleTreeSim.computeRootHash("User:Ali", "Order:101"); // Veriler aynı
    String server3Root = MerkleTreeSim.computeRootHash("User:Ali", "Order:999"); // Veri farklı!

    IO.println("Sunucu 1 ve 2 Eşit mi? " + server1Root.equals(server2Root) + " (Kök: " + server1Root + ")");
    IO.println("Sunucu 1 ve 3 Eşit mi? " + server1Root.equals(server3Root) + " (Uyuşmazlık Var! Senkronize et)");
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
      Mülakatta DynamoDB'nin 'Liderli (Master-based)' bir mimari olduğunu iddia etmeyin! Dynamo lidersizdir (Leaderless); her düğüm eşit yetkilere sahiptir. Bu sayede tek hata noktası (SPOF) barındırmaz.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never describe Dynamo as a master-slave system. Dynamo is strictly decentralized and leaderless; all nodes act as peers, eliminating single points of failure.]
    ]
  )
]

#takeaways_box((
    ("Sloppy Quorum ve Hinted Handoff düğüm arızalarında bile yazma erişilebilirliğini korur.", "Sloppy Quorum and Hinted Handoff guarantee write availability during node downtime."),
    ("Merkle Trees, düğümler arasındaki veri farklarını minimum ağ trafiğiyle senkronize eder.", "Merkle Trees identify replica divergence with minimal network bandwidth overhead."),
    ("Gossip Protocol merkezi bir koordinatör olmadan küme sağlığını merkeziyetsiz yönetir.", "The Gossip protocol maintains decentralized cluster membership and failure detection."),
))
