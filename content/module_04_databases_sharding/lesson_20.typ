#import "/template.typ": *

#show: doc => setup_book(title: "Ders 20: NoSQL Aileleri: Document, Key-Value, Wide-Column (Cassandra) ve Graph", doc)

#lesson_header(
  20,
  "NoSQL Aileleri: Document, Key-Value, Wide-Column (Cassandra) ve Graph",
  "The 4 NoSQL Families: Document, Key-Value, Wide-Column & Graph",
  "Veritabanı Mimarisi, Bölümleme ve Replikasyon",
  "Database Architecture, Sharding & Replication Topologies"
)

#diagram_box[
```text
   [ 1. KEY-VALUE (Redis, DynamoDB) ]        [ 2. DOCUMENT (MongoDB, Couchbase) ]
   "user:101" ──▶ { "name": "Ali" }          JSON/BSON hiyerarşik dokümanlar.
   Ultra hızlı O(1), basit sorgular.          İç içe diziler, esnek indeksleme.

   [ 3. WIDE-COLUMN (Cassandra, ScyllaDB) ]  [ 4. GRAPH (Neo4j, AWS Neptune) ]
   Row Key ──▶ [Col1: Val1] [Col2: Val2]...   Düğümler (Nodes) ve İlişkiler (Edges).
   Milyarlarca satır/sütun, LSM-Tree,         Sosyal ağlar (Arkadaşımın arkadaşı),
   Yazma canavarı (Time-series, IoT).         Dolandırıcılık (Fraud) tespiti.
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      4 farklı alet çantasını düşünün: 1) Key-Value (Redis): Otel vestiyeri gibidir; fiş numarasını verirsiniz, ceketi saniyesinde alırsınız (hızlı ama ceketin cebinde ne olduğunu arayamazsınız). 2) Document (MongoDB): Lüks bir dosya klasörüdür; içinde müşterinin tüm faturaları, fotoğrafları tek bir dosyadadır. 3) Wide-Column (Cassandra): Sonsuz genişlikte devasa bir muhasebe tablosudur; saniyede 1 milyon satır faturayı tıkır tıkır kaydeder (yazma şampiyonu). 4) Graph (Neo4j): Dedektiflerin panosundaki iplerle birbirine bağlanmış fotoğraflardır; 'Ali'nin arkadaşının takip ettiği sayfaları beğenen kim var?' sorusunu şıp diye çözer!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Four specialized power tools: 1) Key-Value (Redis, DynamoDB): A coat check room; you hand over ticket #42, you get coat #42 in 1 millisecond (super fast, but you cannot search coats by collar size). 2) Document (MongoDB): A manila folder storing self-contained rich JSON documents with nested arrays. 3) Wide-Column (Cassandra): An infinite spreadsheet engineered with LSM-Trees that swallows 1,000,000 writes/sec without sweating (IoT, telemetry). 4) Graph (Neo4j): A detective's corkboard with red yarn connecting suspects (Nodes) and crimes (Edges); answering 'Who is a friend-of-a-friend that likes this page?' in milliseconds!]
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
      NoSQL 4 ana kategoriye ayrılır: 1) Key-Value: En basit, en hızlı veri modeli (Redis, Memcached, DynamoDB). Anahtar üzerinden O(1) okuma/yazma. 2) Document Store: JSON/BSON dokümanları (MongoDB, Couchbase). İkincil indeksler (Secondary Indexes) desteklenir; e-ticaret ürün katalogları ve içerik yönetim sistemleri için uygundur. 3) Wide-Column (Columnar Store): Google Bigtable ve Apache Cassandra mimarisi. Veriler sütun aileleri (Column Families) ve Row Key bazında LSM-Tree ile saklanır. Yüksek yazma verimi (Write Throughput) ve zaman serisi (Metrics, Chat geçmişi) için liderdir. 4) Graph Database: Düğümler (Nodes), kenarlar (Edges) ve özellikler (Properties) (Neo4j, Amazon Neptune). Çok katmanlı ilişkisel gezinme (Graph Traversal) sorgularında SQL JOIN'lerinin aksine performans kaybı yaşamaz.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[1) Key-Value (Redis, DynamoDB): Pure O(1) hash maps keyed by unique strings. Minimalist, sub-millisecond, highly partitionable. 2) Document (MongoDB, Couchbase): Semi-structured JSON trees permitting rich secondary indexes and aggregation pipelines, ideal for polymorphic product catalogs. 3) Wide-Column (Cassandra, ScyllaDB): Bigtable-derived sparse multidimensional sorted maps. Optimized with append-only LSM-Trees for extreme write throughput and linear horizontal scaling across IoT feeds, audit logs, and message timelines. 4) Graph (Neo4j, Neptune): Pointer-chasing graph traversal engine executing deep relationship pathfinding (fraud rings, social graphs, recommendation networks) without explosive multi-way SQL JOIN overhead.]
    ]
  )
]

#java25_box[
```java
// Java 25: Graph Veritabanı Mantığı (Düğümler ve İlişkiler Simülasyonu)
import java.util.*;

public class GraphDatabaseSim {
    public record Node(String id, String name) {}
    public record Edge(Node from, Node to, String relation) {}

    private final Map<Node, List<Edge>> adjacencyList = new HashMap<>();

    public void addFriendship(Node a, Node b) {
        adjacencyList.computeIfAbsent(a, k -> new ArrayList<>()).add(new Edge(a, b, "FRIENDS_WITH"));
        adjacencyList.computeIfAbsent(b, k -> new ArrayList<>()).add(new Edge(b, a, "FRIENDS_WITH"));
    }

    public List<Node> getFriendsOfFriends(Node person) {
        Set<Node> fofs = new HashSet<>();
        for (Edge friendEdge : adjacencyList.getOrDefault(person, List.of())) {
            Node friend = friendEdge.to();
            for (Edge fofEdge : adjacencyList.getOrDefault(friend, List.of())) {
                if (!fofEdge.to().equals(person)) {
                    fofs.add(fofEdge.to());
                }
            }
        }
        return new ArrayList<>(fofs);
    }
}

void main() {
    var graph = new GraphDatabaseSim();
    var ali = new GraphDatabaseSim.Node("1", "Ali");
    var bob = new GraphDatabaseSim.Node("2", "Bob");
    var can = new GraphDatabaseSim.Node("3", "Can");

    graph.addFriendship(ali, bob);
    graph.addFriendship(bob, can); // Ali -> Bob -> Can

    IO.println("Ali'nin Arkadaşının Arkadaşları: " + graph.getFriendsOfFriends(ali).getFirst().name());
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
      Cassandra gibi Wide-Column sistemlerde 'İstediğim sütuna göre sonradan SELECT WHERE çekerim' diyemezsiniz! Cassandra'da sorgular Partition Key ve Clustering Key'e göre KATI bir şekilde önceden modellenmelidir; sorgu desenini bilmeden tablo tasarlanamaz.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[In Cassandra, you cannot run arbitrary ad-hoc queries with WHERE clauses on non-key columns without table scans. In Wide-Column stores, table schemas are rigidly designed around explicit query access patterns.]
    ]
  )
]

#takeaways_box((
    ("Key-Value basit nesneler ve oturumlar için en hızlı NoSQL türüdür.", "Key-Value stores offer unmatched speed for simple session and payload caches."),
    ("Cassandra LSM-Tree yapısı sayesinde saniyede milyonlarca yazmayı kayıpsız yutar.", "Cassandra's append-only LSM-Tree architecture excels at high-velocity writes."),
    ("Sosyal ağ ve dolandırıcılık tespiti gibi ilişkisel ağlarda Graph DB rakipsizdir.", "Graph databases conquer multi-hop relationship pathfinding with zero JOIN degradation."),
))
