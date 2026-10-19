#import "/template.typ": *

#show: doc => setup_book(title: "Ders 5: CAP Teoremi ve PACELC: Ağ Bölünmesinde Tutarlılık mı, Erişilebilirlik mi?", doc)

#lesson_header(
  5,
  "CAP Teoremi ve PACELC: Ağ Bölünmesinde Tutarlılık mı, Erişilebilirlik mi?",
  "CAP Theorem & PACELC: Consistency vs Availability",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
        [ CAP TEOREMİ: YALNIZCA 2'SİNİ SEÇEBİLİRSİNİZ ]
                         Consistency (Tutarlılık)
                               ▲
                              / \
                             /   \
                      CP    /     \   CA (Ağda bölünme yoksa)
                           /  CAP  \
                          /         \
                         /___________\
      Availability (Erişilebilirlik)  Partition Tolerance (Bölünme Toleransı)
                                AP

  PACELC Eklentisi:
  Ağ Bölünmesi Varsa (If Partition - P): [A]vailability mi [C]onsistency mi?
  Normal Durumda (Else - E):             [L]atency mi [C]onsistency mi?
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir bankanın Ankara ve İstanbul şubelerini düşünün. İki şube arasındaki telefon ve internet kablosu bir kaza sonucu koptu (Ağ Bölünmesi - Partition). Şimdi Ankara şubesine bir müşteri gelip hesabındaki son 1.000 TL'yi çekmek istiyor. Banka ne yapmalı? 1) 'İnternet koptu, işlem yapamam' deyip müşteriyi geri çevirirse Tutarlılığı (Consistency - CP) seçmiş olur. 2) 'Parayı verelim gitsin, kablo bağlanınca bakarız' derse Erişilebilirliği (Availability - AP) seçmiş olur ama müşteri aynı parayı İstanbul'dan da çekmiş olabilir! İkisini aynı anda garanti edemezsiniz!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine two bank branches in New York and London. A submarine cable snaps, severing their communication line (Network Partition). A customer walks into London wanting to withdraw their last \$1,000. What does the bank do? 1) Refuse the withdrawal until connection restores: chooses Consistency over Availability (CP). 2) Hand over the cash: chooses Availability over Consistency (AP), risking that the customer simultaneously withdrew the same \$1,000 in New York! You cannot have both!]
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
      Eric Brewer'ın CAP Teoremi: Dağıtık bir veri deposu Consistency (Lineerize edilebilir anlık tutarlılık), Availability (Her sağlıklı düğümün hata yerine yanıt dönmesi) ve Partition Tolerance (Ağ paketleri kaybolsa da sistemin çalışması) özelliklerinden aynı anda ancak ikisini sağlayabilir. Dağıtık ağlarda kablo kopmaları ve gecikmeler kaçınılmaz olduğundan 'P' zorunludur; dolayısıyla gerçek dünya seçimi CP veya AP arasındadır. Daniel Abadi'nin PACELC teoremi bunu genişletir: Ağ bölünmesi yokken bile sistem Düşük Gecikme (Latency) mi yoksa Güçlü Tutarlılık (Consistency) mi hedefliyor? (Örn: MongoDB = PC/EC, Cassandra = PA/EL).
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[Brewer's CAP Theorem proves that a distributed data store can guarantee at most two of: Consistency (linearizability), Availability (every non-failing node returns a non-error response), and Partition Tolerance (network packet drops/splits). Since network partitions are an inevitable physical reality, 'P' is non-negotiable, boiling trade-offs down to CP vs AP. Abadi's PACELC expands this: If partitioned (P), trade Availability (A) vs Consistency (C); Else (E), trade Latency (L) vs Consistency (C). Example: Dynamo/Cassandra = PA/EL, HBase/Spanner = PC/EC.]
    ]
  )
]

#java25_box[
```java
// Java 25: CAP/PACELC Modeli ve Quorum Tutarlılık Kontrolcüsü
public class QuorumConsistencyChecker {
    // R (Okuma Düğümü), W (Yazma Düğümü), N (Toplam Replika)
    // Güçlü Tutarlılık Kuralı: R + W > N
    public static boolean isStronglyConsistent(int totalNodes, int writeQuorum, int readQuorum) {
        return (writeQuorum + readQuorum) > totalNodes;
    }

    public static void main(String[] args) {
        int N = 3; // 3 Replikasyonlu Küme
        int W = 2; // Çoğunluk yazma (Quorum Write)
        int R = 2; // Çoğunluk okuma (Quorum Read)

        boolean strong = isStronglyConsistent(N, W, R);
        IO.println("R=" + R + ", W=" + W + ", N=" + N + " -> Güçlü Tutarlı mı? " + strong);
        // R + W = 4 > 3 -> En az 1 düğüm hem en son yazmayı hem okumayı görür!
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
      Mülakatçılar 'Ben hem %100 tutarlı hem de her durumda anında cevap veren bir sistem istiyorum' diyerek sizi tuzağa düşürmeye çalışır. Tuzağa düşmeyin: Ağ bölünmesinde CAP gereği birinden ödün vermek zorunda olduğunuzu netçe ifade edin.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Interviewers often bait candidates by asking for 100% consistency AND 100% availability during network partitions. Stand firm: explain that network splits make this mathematically impossible under CAP.]
    ]
  )
]

#takeaways_box((
    ("Gerçek dünyada ağ bölünmeleri (P) kaçınılmazdır; seçim CP veya AP arasındadır.", "Network partitions (P) are unavoidable; real architectures choose between CP and AP."),
    ("Finansal ve bakiye sistemleri CP'yi, sosyal medya akışları ve beğeniler AP'yi tercih eder.", "Financial ledger ledgers favor CP; social media feeds and likes favor AP."),
    ("PACELC teoremi, sistemin normal zamanlardaki Latency vs Consistency takasını açıklar.", "PACELC clarifies the everyday trade-off between latency and consistency when no partition exists."),
))
