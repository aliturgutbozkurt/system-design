#import "/template.typ": *

#show: doc => setup_book(title: "Ders 54: Canlı Oyun Lider Tablosu (Gaming Leaderboard): Redis Sorted Sets ve SkipList", doc)

#lesson_header(
  54,
  "Canlı Oyun Lider Tablosu (Gaming Leaderboard): Redis Sorted Sets ve SkipList",
  "Designing a Real-Time Gaming Leaderboard: Redis ZSET & SkipLists",
  "İleri Seviye MAANG Tasarım Problemleri",
  "Advanced MAANG Distributed System Designs"
)

#diagram_box[
```text
   [ REDIS SORTED SET (ZSET) İÇ MİMARİSİ: SKIPLIST (ATLAMALI LİSTE) ]
   Kullanıcı skorları logaritmik O(log N) sürede sıralanır ve güncellenir:

   Level 3: [Head] ─────────────────────────────────────────────▶ [Skor: 1500] ──▶ null
   Level 2: [Head] ────────────────▶ [Skor: 800] ───────────────▶ [Skor: 1500] ──▶ null
   Level 1: [Head] ──▶ [Skor: 300] ──▶ [Skor: 800] ──▶ [Skor: 950] ──▶ [Skor: 1500] ──▶ null
   (10 Milyon oyuncu olsa bile 25 atlamada oyuncunun dünya sıralaması bulunur!)

   [ LEADERBOARD SORGULARI ]
   1. ZADD leaderboard 1500 "user_ali"  ──▶ Skoru O(log N) sürede güncelle
   2. ZREVRANK leaderboard "user_ali"   ──▶ Ali'nin dünya sıralamasını getir (1. sıra)
   3. ZREVRANGE leaderboard 0 9 WITHSCORES ──▶ Dünya Top-10 listesini anında getir!
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      10 milyon kişinin aynı anda oynadığı bir mobil oyunu düşünün. Herkes canavar öldürdükçe puanı artıyor. 'Ben dünyada kaçıncı sıradayım?' dediğinizde, 10 milyon kişiyi sıfırdan küçükten büyüğe sıralamaya kalkarsanız oyun donar! Redis Sorted Set işte bu yüzden sihirli bir ekspres trene (SkipList) benzer: En alt katta her istasyon vardır; ama üst katlarda sadece ana istasyonlar vardır. Tren üst kattan son hızla atlayarak gider ve 10 milyon kişi arasından sizin sıranızı göz açıp kapayıncaya kadar (1 milisaniyede) bulup çıkarır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[In a mobile game with 10 million active players, scores fluctuate every microsecond. If querying 'What is my global rank?' forced the database to run an \$O(N \log N)\$ sort across 10 million rows, servers would melt! Redis Sorted Sets solve this using a multi-level express subway called a SkipList. The bottom track stops at every single station, while elevated tracks skip 10 or 100 stations at a time. The algorithm rides the express tracks, finding any player's exact global rank among 10 million contenders in under 1 millisecond (\$O(\log N)\$)!]
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
      MAANG Oyun Lider Tablosu Mimarisi: 1) Neden İlişkisel DB Yetmez? Milyonlarca oyuncunun olduğu bir tabloda `SELECT COUNT(*) WHERE score > my_score` sorgusu tam bir felakettir; her puan değişiminde indeks kilitlenir. 2) Redis ZSET (Sorted Set): İki veri yapısının mükemmel birleşimidir: A) HashMap: Oyuncu adına göre skoru \$O(1)\$ sürede bulur. B) SkipList (Atlamalı Liste): Skorları sıralı tutar. Skor güncelleme (`ZADD`), sıralama bulma (`ZREVRANK`) ve aralık okuma (`ZREVRANGE`) \$O(\log N)\$ sürede biter. 10 milyonluk bir tabloda \$\log_2(10^7) \approx 24\$ işlemde sonuç alınır. 3) Eşit Puanların Ayrılması: İki oyuncu aynı puana sahipse (ör. ikisi de 1500), skora zaman damgası eklenerek erken puan alan öne geçirilir: `EfektifSkor = Skor - (Timestamp / 10^13)`.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Scale Gaming Leaderboard Architecture: 1) Relational DB Breakdown: Executing `SELECT COUNT(*) FROM leaderboard WHERE score > user_score` executes full table/index scans that crush concurrency. 2) Redis ZSET (Sorted Set Duality): Blends a Hash Map (for \$O(1)\$ player lookup) with a probabilistic multi-level SkipList (for \$O(\log N)\$ insertions, removals, and rank lookups). For a leaderboard of 10 million gamers, traversing the SkipList requires at most \$\approx 24\$ pointer hops. 3) Common Leaderboard APIs: `ZADD leaderboard score user_id` updates a score; `ZREVRANK leaderboard user_id` returns global rank; `ZREVRANGE leaderboard 0 9` fetches the global Top-10. 4) Tie-Breaking Mechanics: When two players share identical scores (e.g. 1500 points), prioritize the player who achieved it first by subtracting a scaled epoch timestamp: `CompositeScore = Score + (1 - (Timestamp / 10^13))`.]
    ]
  )
]

#java25_box[
```java
// Java 25: Eşit Puanları Zaman Damgasıyla Çözen Lider Tablosu Skoru
public class LeaderboardScoreCalculator {
    // Eşit puanlarda önce ulaşanı üst sıraya taşıyan formül:
    public static double computeCompositeScore(long points, long timestampMillis) {
        // Puan tamsayı kısmında kalır, zaman damgası kesirli kısma küçük bir eksi olarak eklenir
        double timePenalty = (double) timestampMillis / 1_000_000_000_000.0;
        return points + (1.0 - (timePenalty % 1.0));
    }
}

void main() {
    long score = 2500;
    long timeAli = 1700000000000L;       // Ali saat 12:00'de ulaştı
    long timeVeli = 1700000060000L;      // Veli 1 dakika sonra ulaştı

    double aliComposite = LeaderboardScoreCalculator.computeCompositeScore(score, timeAli);
    double veliComposite = LeaderboardScoreCalculator.computeCompositeScore(score, timeVeli);

    IO.println("Ali'nin Skoru:  " + String.format("%.8f", aliComposite));
    IO.println("Veli'nin Skoru: " + String.format("%.8f", veliComposite));
    IO.println("Ali Veli'den Önde mi? " + (aliComposite > veliComposite)); // TRUE!
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
      Mülakatta 'Dünya Top-100 listesini her oyuncunun ekranında saniyede 1 kez polling ile yenilerim' demeyin! 5 milyon aktif oyuncu saniyede 5 milyon istek demektir. Top-100 listesi CDN veya yerel bellek önbelleğinde 5 saniyelik bir TTL ile tutulmalı, kullanıcının kendi sırası WebSocket ile sadece değiştikçe iletilmelidir.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Polling the global Top-100 leaderboard every second from millions of mobile clients will saturate Redis network bandwidth. Cache the Top-100 at CDN edge PoPs with a 5-second TTL, pushing personalized rank mutations over WebSockets only when milestones cross.]
    ]
  )
]

#takeaways_box((
    ("Redis ZSET (SkipList) 10 milyonluk kümelerde bile sıralamayı O(log N) sürede bulur.", "Redis ZSETs leverage SkipLists to resolve user ranks in O(log N) time across millions of users."),
    ("Eşit puanlarda (Tie-Breaking) zaman damgası eklenerek erken ulaşan ödüllendirilir.", "Composite scoring incorporates timestamp fractions to break score ties deterministically."),
    ("Top-100 gibi global listeler CDN seviyesinde kısa TTL ile önbelleğe alınarak Redis korunur.", "Edge-caching Top-100 leaderboards protects Redis from millions of redundant read queries."),
))
