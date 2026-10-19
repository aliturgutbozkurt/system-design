#import "/template.typ": *

#show: doc => setup_book(title: "Ders 47: Arama Otomatik Tamamlama (Typeahead / Google Suggestion): Trie ve Redis ZSET", doc)

#lesson_header(
  47,
  "Arama Otomatik Tamamlama (Typeahead / Google Suggestion): Trie ve Redis ZSET",
  "Designing Search Typeahead (Google Suggestion): Trie & Redis ZSET",
  "Klasik MAANG Tasarım Problemleri - Bölüm 2",
  "Classic MAANG System Designs - Part 2"
)

#diagram_box[
```text
   [ TRIE (ÖNEK AĞACI / PREFIX TREE) VERİ YAPISI ]
   Kelimeler: "sistem" (1000 ara), "siber" (500 ara), "spring" (2000 ara)

                         (Root)
                           │
                           ▼ 's'
                          (s)
                         /   \
                  'i'   /     \  'p'
                       (i)     (p)
                      /   \     │ 'r'
               's'   /     \ 'b'(r)
                   (s)     (b)  │ 'i' -> "spring" (Top-1 Popüler!)
                    │       │
              "sistem"   "siber"
   (Her düğümde en popüler Top-5 kelime önceden saklanır -> O(1) anında arama!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Google'ın arama kutusuna 'sis' yazdığınız anda kutunun altında 'sistem tasarımı', 'siber güvenlik' gibi önerilerin şak diye belirmesini düşünün. Dünyada 1 milyar kelime varken Google her harf bastığınızda tüm veritabanını tarayamaz! Bunun yerine akıllı bir soy ağacı (Trie - Önek Ağacı) kurar. 's' harfine basınca 's' ile başlayan tüm dalları, 'i' harfine basınca 'si' ile başlayan dalları görür. Üstelik her dalın tepesinde en çok aranan ilk 5 kelime altın tepside hazır tutulur. Siz tuşa bastığınız anda 2 milisaniyede liste önünüze dökülür!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[The instant you type 'sys' into Google, a dropdown flashes: 'system design', 'system requirements'. With a corpus of billions of search terms, Google cannot run a database SQL scan on every keystroke! Instead, it navigates an in-memory Prefix Tree (Trie). Typing 's' lands on the 's' branch; typing 'y' traverses to 'sy'. Crucially, every tree node pre-caches the Top-5 most popular global search phrases right on its branch. The moment your finger hits the key, suggestions render in 2 milliseconds!]
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
      MAANG Typeahead Mimarisi: 1) Trie Veri Yapısı: Kökten yapraklara karakter bazlı dallanan ağaçtır. Arama süresi kelime uzunluğu \$k\$ kadardır (\$O(k)\$); kelime sayısından (\$N\$) tamamen bağımsızdır. 2) Top-K Önbellekleme: Her Trie düğümünde en sık aranan ilk 5-10 kelime ve frekansı saklanır. Kullanıcı 'sis' yazdığında ağacın derinliklerine inmeden o düğümdeki hazır listeyi döner (\$O(1)\$). 3) Çevrimdışı Analiz Hattı (Offline Aggregation Pipeline): Trie çalışma anında güncellenmez (yavaşlatmamak için). Arama logları Kafka -> Flink/Spark ile toplanır; gece batch işinde yeni frekanslar hesaplanır ve güncel Trie bellek kümesine (Redis veya Custom C++ / Java servisi) yüklenir. 4) İstemci Tarafı Optimizasyon: Tarayıcı tarafında 200ms `debounce` (kullanıcı yazmayı bırakana kadar bekleme) ve yerel önbellek uygulanır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG Search Typeahead Architecture: 1) The Trie Data Structure: Character-level prefix tree providing \$O(L)\$ traversal time (\$L\$ = query length), completely independent of total vocabulary size \$N\$. 2) Node-Level Top-K Caching: To eliminate subtree traversals during runtime lookups, each Trie node caches the Top-5 most frequent completions directly on its node struct. Querying prefix 'sys' reads the pre-computed Top-5 array in \$O(1)\$ time. 3) Offline Aggregation Pipeline: Live search keystrokes stream into Kafka and map-reduce via Apache Flink to aggregate weekly frequency scores. Updated Trie snapshots rebuild offline and hot-swap into distributed memory clusters. 4) Client-Side Optimizations: Frontends implement a 200ms debounce buffer and local LRU cache to slash upstream keystroke queries by 60%.]
    ]
  )
]

#java25_box[
```java
// Java 25: Top-K Destekli Trie (Önek Ağacı) Implementasyonu
import java.util.*;

public class TypeaheadTrie {
    private static class TrieNode {
        Map<Character, TrieNode> children = new HashMap<>();
        List<String> topSuggestions = new ArrayList<>(); // Önceden hesaplanmış Top-K
    }

    private final TrieNode root = new TrieNode();

    public void insert(String phrase) {
        TrieNode curr = root;
        for (char c : phrase.toLowerCase().toCharArray()) {
            curr = curr.children.computeIfAbsent(c, k -> new TrieNode());
            if (!curr.topSuggestions.contains(phrase)) {
                if (curr.topSuggestions.size() < 3) {
                    curr.topSuggestions.add(phrase);
                }
            }
        }
    }

    public List<String> getSuggestions(String prefix) {
        TrieNode curr = root;
        for (char c : prefix.toLowerCase().toCharArray()) {
            curr = curr.children.get(c);
            if (curr == null) return List.of();
        }
        return curr.topSuggestions;
    }
}

void main() {
    var trie = new TypeaheadTrie();
    trie.insert("sistem tasarimi");
    trie.insert("siber guvenlik");
    trie.insert("sistem gereksinimleri");
    trie.insert("spring boot action");

    IO.println("Öneri ('sis'): " + trie.getSuggestions("sis"));
    IO.println("Öneri ('sp'):  " + trie.getSuggestions("sp"));
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
      Mülakatta Trie ağacını her kullanıcı arama yaptıkça canlı (real-time) olarak güncelleyeceğinizi söylemeyin! Milyonlarca eşzamanlı yazma işlemi Trie ağacında kilitlenme (Lock Contention) yaratır ve belleği tüketir. Güncellemeler daima çevrimdışı batch pipeline ile yapılmalıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never propose updating Trie frequencies synchronously on live search queries. Concurrent lock contention on root nodes will crater latency. All frequency score recalculations must occur asynchronously via offline batch pipelines.]
    ]
  )
]

#takeaways_box((
    ("Trie (Önek Ağacı) arama süresini kelime sayısından bağımsız olarak O(kelime_uzunluğu) yapar.", "Tries bound search latency to O(prefix_length), completely independent of dictionary scale."),
    ("Düğüm üzerinde Top-K önbellekleme arama anında tüm ağacı tarama zorunluluğunu kaldırır.", "Pre-computing Top-K suggestions at each Trie node delivers instant O(1) query returns."),
    ("İstemci tarafında Debouncing (200ms) uygulamak sunucuya gelen istek yükünü %60 azaltır.", "Client-side debouncing buffers rapid typing, cutting keystroke query volume by 60%+."),
))
