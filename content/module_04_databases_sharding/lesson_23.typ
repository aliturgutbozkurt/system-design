#import "/template.typ": *

#show: doc => setup_book(title: "Ders 23: Tutarlı Karışıklık (Consistent Hashing) & Sanal Düğümler (Virtual Nodes)", doc)

#lesson_header(
  23,
  "Tutarlı Karışıklık (Consistent Hashing) & Sanal Düğümler (Virtual Nodes)",
  "Consistent Hashing & Virtual Nodes: The Elastic Scaling Ring",
  "Veritabanı Mimarisi, Bölümleme ve Replikasyon",
  "Database Architecture, Sharding & Replication Topologies"
)

#diagram_box[
```text
   [ TUTARLI KARIŞIKLIK HALKASI (CONSISTENT HASH RING: 0 -> 2^32 - 1) ]
                                 Düğüm A (Sanal 1)
                                      0 / 360°
                                    ▲
                                   / \
             Düğüm C (Sanal 2)    /   \     Anahtar 1 (Düğüm B'ye gider)
                                 │  O  │
             Anahtar 2           │     │     Düğüm B (Sanal 1)
                                  \   /
                                   \ /
                                    ▼
                                 Düğüm C (Sanal 1)
   (Saat yönünde dön! Bir sunucu eklenirse/silinirse verinin yalnızca k/N'i taşınır!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Geleneksel modülo aritmetiğinde (`Hash % N`), 4 sunucunuz varken 5. sunucuyu eklerseniz sınıftaki herkesin sırası değişir; tüm önbellek geçersiz kalır ve veritabanı çöker! Consistent Hashing ise yuvarlak bir yemek masası gibidir (0'dan 360 dereceye bir çember). Sunucuları masanın etrafına rastgele oturtursunuz. Yeni gelen bir yemeği masanın üzerine koyup saat yönünde döndürürsünüz; yemeği ilk gören sunucu onu afiyetle yer! Masaya yeni bir sandalye koysanız bile sadece o sandalyenin hemen yanındaki birkaç yemek yer değiştirir; geri kalan herkes yemeğini yemeye devam eder!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Under naive modular hashing (`hash % N`), expanding from 4 to 5 servers scrambles the destination of 80% of all keys, triggering a total cache wipeout! Consistent Hashing is an infinite circular conference table (0 to 2^32 - 1). You position servers at discrete degrees around the circle. To store a key, hash it to a point on the circle and walk clockwise: the first server node you bump into claims the key! If a new server pulls up a chair, only its immediate neighbor hands over a sliver of keys; the remaining 80% of data stays completely untouched!]
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
      Consistent Hashing (Karger ve arkadaşları, MIT 1997), dağıtık önbellek (Memcached, Akamai CDN) ve NoSQL (Amazon DynamoDB, Apache Cassandra) mimarilerinin kalbidir. Avantajı: Kümedeki düğüm sayısı N değiştiğinde, taşınması gereken anahtar sayısı geleneksel mimarideki gibi %100 değil, sadece ortalama k/N kadardır (k = toplam anahtar). Sanal Düğümler (Virtual Nodes / Vnodes): Fiziksel bir sunucunun halka üzerinde tek bir noktada durması 'Hotspot' ve dengesiz yük dağılımına yol açar. Çözüm: Her fiziksel sunucuya halka üzerinde 100-256 adet sanal etiket atanır (`NodeA-1`, `NodeA-2`...). Bu sayede yük çember boyunca mükemmel bir homojenlikle dağılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Consistent Hashing maps both servers and data keys onto a continuous hash ring (typically 0 to 2^32 - 1). Keys route clockwise to the first encountered server token. When node scaling occurs, only k/N keys migrate (k = total keys, N = server count), avoiding mass cache evictions. The Virtual Nodes (Vnodes) Innovation: A physical server represented by a single token risks severe load skew due to random clustering. By projecting each physical node into 100-256 virtual points across the ring perimeter, keys distribute uniformly across hardware proportional to host capacity.]
    ]
  )
]

#java25_box[
```java
// Java 25: Sanal Düğümlü (Vnodes) Consistent Hash Halkası Implementasyonu
import java.util.*;

public class ConsistentHashRing<T> {
    private final int numberOfReplicas; // Sanal düğüm sayısı
    private final SortedMap<Integer, T> circle = new TreeMap<>();

    public ConsistentHashRing(int numberOfReplicas, Collection<T> nodes) {
        this.numberOfReplicas = numberOfReplicas;
        for (T node : nodes) addNode(node);
    }

    public void addNode(T node) {
        for (int i = 0; i < numberOfReplicas; i++) {
            circle.put(hash(node.toString() + "-vnode-" + i), node);
        }
    }

    public T getNode(String key) {
        if (circle.isEmpty()) return null;
        int hash = hash(key);
        if (!circle.containsKey(hash)) {
            SortedMap<Integer, T> tailMap = circle.tailMap(hash);
            hash = tailMap.isEmpty() ? circle.firstKey() : tailMap.firstKey(); // Saat yönünde dön
        }
        return circle.get(hash);
    }

    private int hash(String val) {
        return val.hashCode() & 0x7fffffff;
    }
}

void main() {
    var ring = new ConsistentHashRing<String>(3, List.of("Server-A", "Server-B", "Server-C"));
    IO.println("Key 'user_9912' Hangi Sunucuda? -> " + ring.getNode("user_9912"));
    IO.println("Key 'order_441' Hangi Sunucuda?  -> " + ring.getNode("order_441"));
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
      Mülakatta sanal düğümleri (Virtual Nodes) anlatmayı unutursanız mülakatçı 'Düğümler halkaya rastgele düşerse biri aşırı yüklenip çökmez mi?' diye soracaktır. Sanal düğümlerin varyansı düşürüp yükü homojenleştirdiğini doğrudan siz söyleyin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Failing to proactively propose Virtual Nodes (Vnodes) invites the interviewer to challenge you on hash skew. Preemptively demonstrate that virtual tokens equalize ring dispersion and reflect asymmetric server hardware.]
    ]
  )
]

#takeaways_box((
    ("Consistent Hashing, sunucu ekleme/çıkarmada veri taşıma maliyetini k/N seviyesine indirir.", "Consistent Hashing bounds key migration to k/N upon node churn, preserving cache stability."),
    ("Sanal Düğümler (Virtual Nodes) çember üzerindeki yükü mükemmel dengeler ve hotspot'u önler.", "Virtual Nodes neutralize non-uniform distribution skew across heterogeneous machines."),
    ("DynamoDB, Cassandra ve Discord gibi devasa dağıtık sistemlerin temel omurgasıdır.", "Serves as the structural backbone of Amazon DynamoDB, Apache Cassandra, and Discord."),
))
