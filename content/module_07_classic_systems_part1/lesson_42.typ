#import "/template.typ": *

#show: doc => setup_book(title: "Ders 42: Yakındaki Yerler / Mekan Arama Servisi (Proximity / Yelp): Geohash vs QuadTree vs Google S2", doc)

#lesson_header(
  42,
  "Yakındaki Yerler / Mekan Arama Servisi (Proximity / Yelp): Geohash vs QuadTree vs Google S2",
  "Designing a Proximity Service (Yelp / Google Maps): Geohash vs QuadTree",
  "Klasik MAANG Tasarım Problemleri - Bölüm 1",
  "Classic MAANG System Designs - Part 1"
)

#diagram_box[
```text
   [ COĞRAFİ ALAN İNDEKSLERİ (GEOHASH vs QUADTREE) ]

   1. GEOHASH (Base32 Kodlama)             2. QUADTREE (4 Parçalı Hiyerarşik Ağaç)
   Dünya ızgaralara (grid) bölünür:                ┌───────┬───────┐
   "u10j4" ──▶ 1.2km x 600m alan                   │  NW   │  NE   │
   "u10j4b"──▶ 150m x 150m alan                    ├───────┼───────┤
   (Ortak önek = Fiziksel yakınlık!)               │  SW   │  SE   │
   Komşu araması: 8 komşu kutu sorgulanır!         └───────┴───────┘
                                                   (Nüfus yoğunsa alt 4 parçaya bölünür!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Haritada 'Bana en yakın 10 kahveciyi bul' dediğinizde, dünyadaki 500 milyon kahvecinin koordinatını tek tek Pisagor teoremiyle (\$x^2 + y^2\$) hesaplamaya çalışırsanız sunucu patlar! Bunun yerine dünya bir satranç tahtası gibi karelere bölünür (Geohash). Her karenin posta kodu gibi bir adı vardır (ör. 'u10j4'). Siz o karenin içindeyseniz, sistem sadece o karenin ve etrafındaki 8 komşu karenin içindeki kahvecilere bakar. 500 milyon dükkan yerine sadece 50 dükkana bakarak 1 milisaniyede sonucu bulur!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Searching 'Find the 10 closest cafes near me' cannot compute the Pythagorean distance formula across all 500 million cafes worldwide on every GPS ping! Instead, divide the planet into an indexed grid of boxes (Geohash). Each grid box gets an alphanumeric postal code (e.g. `u10j4`). When you query from that box, the system simply queries that box plus its 8 immediate neighboring boxes. The search space shrinks from 500 million points down to 50 in 1 millisecond!]
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
      MAANG Seviyesi Mekan Arama (Proximity) Mimarisi: 1) Neden Standart SQL İndeksi Yetmez? Enlem (Latitude) ve Boylam (Longitude) iki boyutlu veridir; standart B-Tree indeksinde `WHERE lat BETWEEN ... AND lon BETWEEN ...` sorgusu indeks birleştirmesi (Index Merge) yüzünden çok yavaştır. 2) Geohash: Enlem ve boylamı iç içe geçirerek Base32 karakter dizisine kodlar (1D string). Özellik: Ortak önek (Prefix) paylaşan noktalar fiziksel olarak birbirine yakındır (Örn: `u10j4` 6 karakter ≈ 1.2 km). Kenar etkisi (Edge Effect) için merkez kutu + 8 komşu kutu sorgulanır. Redis `GEOADD` ve `GEORADIUS` komutları arka planda Geohash ve Sorted Set kullanır. 3) QuadTree: Her düğümün en fazla 4 çocuk düğümü olan hiyerarşik ağaçtır. Düğümdeki mekan sayısı eşiği (ör. 100 dükkan) aşınca o alan 4 alt parçaya bölünür (Yoğun şehir merkezlerinde derin, okyanusta sığ ağaç). 4) Google S2: Dünyayı küp projeksiyonu ve Hilbert Eğrisi ile 64-bit tam sayılara böler; Google Haritalar'ın standardıdır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG Proximity Service Architecture: 1) The 2D Spatial Indexing Challenge: Traditional B-Trees index single dimensions efficiently; evaluating `WHERE lat BETWEEN x AND y AND lon BETWEEN a AND b` degrades to full table filtering. 2) Geohash: Interleaves binary bits of latitude and longitude into a Base32 string. Key Trait: Strings sharing prefixes share spatial proximity (`u10j4` has ~1.2km precision). The Boundary Problem: Two adjacent points across a boundary can share completely different prefixes; solved by querying the central box plus its 8 surrounding neighbor cells. Redis native geospatial commands (`GEOADD`, `GEOSEARCH`) leverage 52-bit Geohashes within Sorted Sets. 3) QuadTree: In-memory 2D spatial tree where each quadrant recursively splits into 4 sub-quadrants when point density exceeds a threshold (e.g., 100 POIs). Deeply sub-divided in Manhattan; undivided across deserts. 4) Google S2 Geometry: Projects the spherical earth onto a cube using Space-Filling Hilbert Curves into 64-bit integers; de facto standard for Uber and Google Maps.]
    ]
  )
]

#java25_box[
```java
// Java 25: Basitleştirilmiş Geohash Önek Eşleme ve Komşu Filtreleme
import java.util.*;

public class GeohashProximityEngine {
    public record Place(String name, String geohash6) {}

    private final Map<String, List<Place>> geohashIndex = new HashMap<>();

    public void indexPlace(Place place) {
        geohashIndex.computeIfAbsent(place.geohash6(), k -> new ArrayList<>()).add(place);
    }

    public List<Place> searchNearby(String userGeohash5Prefix) {
        List<Place> results = new ArrayList<>();
        // 5 karakterlik önek (~4.9 km x 4.9 km alan) ile başlayan tüm yerleri topla
        for (var entry : geohashIndex.entrySet()) {
            if (entry.getKey().startsWith(userGeohash5Prefix)) {
                results.addAll(entry.getValue());
            }
        }
        return results;
    }
}

void main() {
    var engine = new GeohashProximityEngine();
    engine.indexPlace(new GeohashProximityEngine.Place("Kadıköy Kahvecisi", "sxk97a"));
    engine.indexPlace(new GeohashProximityEngine.Place("Moda Dondurmacısı", "sxk97b"));
    engine.indexPlace(new GeohashProximityEngine.Place("Ankara Cafe", "sx5f2a"));

    IO.println("Kadıköy (sxk97) Civarındaki Mekanlar:");
    for (var p : engine.searchNearby("sxk97")) {
        IO.println("• " + p.name() + " [Geohash: " + p.geohash6() + "]");
    }
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
      Mülakatta mekan bilgilerinin (isim, adres, menü) QuadTree veya Redis'in içinde saklanacağını söylemeyin! Mekan verisi (metadata) PostgreSQL/MySQL'de tutulur; QuadTree veya Geohash indeksinde SADECE `Place_ID` ve `Geohash` tutulmalıdır. Aksi halde önbellek belleği çöker.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Do not pack heavy business payloads (reviews, menu photos, descriptions) inside the spatial QuadTree/Geohash index. The spatial index must hold only compact `(Place_ID, Coordinates)` tuples; full metadata is resolved from the primary DB.]
    ]
  )
]

#takeaways_box((
    ("Geohash 2D koordinatları tek boyutlu string'lere dönüştürerek hızlı arama sağlar.", "Geohash flattens 2D coordinates into 1D strings, enabling standard index range queries."),
    ("Kenar etkisi (Boundary Effect) problemini çözmek için merkez hücre + 8 komşu taranır.", "Mitigate Geohash boundary cliffs by querying the central cell plus its 8 adjacent neighbors."),
    ("QuadTree bellek içi yoğunluğa göre dinamik olarak alt parçalara bölünür.", "QuadTrees adapt dynamically to population density, allocating deep nodes only in dense cities."),
))
