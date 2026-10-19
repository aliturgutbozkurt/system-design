#import "/template.typ": *

#show: doc => setup_book(title: "Ders 4: Güvenilirlik ve Kullanılabilirlik (SLA, SLO, SLI & 9'lar Kuralı)", doc)

#lesson_header(
  4,
  "Güvenilirlik ve Kullanılabilirlik (SLA, SLO, SLI & 9'lar Kuralı)",
  "Reliability & Availability (SLA, SLO, SLI & The Rule of 9s)",
  "Temel İlkeler, Ölçeklenebilirlik ve Mülakat Çerçevesi",
  "Core Fundamentals, Scalability & The MAANG Interview Framework"
)

#diagram_box[
```text
   [ KULLANILABİLİRLİK VE DOKUZLAR KURALI / DOWNTIME BUDGET ]
  ┌───────────────┬──────────────────────┬───────────────────────────────┐
  │ DOKUZLAR      │ KULLANILABİLİRLİK    │ YILLIK İZİN VERİLEN KESİNTİ   │
  ├───────────────┼──────────────────────┼───────────────────────────────┤
  │ 2 Dokuz (99%) │ Standart Web Sitesi  │ 3 Gün 15 Saat 36 Dakika       │
  │ 3 Dokuz (99.9%)│ Kurumsal SaaS       │ 8 Saat 45 Dakika 57 Saniye    │
  │ 4 Dokuz (99.99%)│ MAANG Altyapısı   │ 52 Dakika 36 Saniye (Hedef!)  │
  │ 5 Dokuz (99.999%)│ Telekomünikasyon │ 5 Dakika 15 Saniye (Kritik!)  │
  └───────────────┴──────────────────────┴───────────────────────────────┘
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir su tesisatçısı düşünün: 'Haftada bir gün musluktan su akmazsa sorun etmeyin' derse (%85 kullanılabilirlik) o tesisatçıyla çalışmazsınız. Ancak bir hastanede 'Yılda sadece 5 dakika elektrikler kesilebilir' derlerse (%99.999 - 5 dokuz), bu ameliyathanenin jeneratörlerle, çift hatlarla ve kusursuz bir mimariyle korunduğunu gösterir. MAANG mülakatında 'Sistemim %99.99 ayakta kalacak' dediğinizde, yılda sadece 52 dakika hata lüksünüz olduğunu bilerek konuşmalısınız!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Imagine a water utility saying: 'If water vanishes for an entire day every month, don't worry about it' (85% availability). You would fire them instantly! But an intensive-care hospital says: 'Power failure cannot exceed 5 minutes over an entire calendar year' (99.999% - Five Nines). That demands redundant generators, dual power grids, and fault-tolerant architecture. When promising 99.99% availability in a MAANG interview, you are budgeting a razor-thin 52 minutes of total annual downtime!]
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
      Üç temel güvenilirlik kavramı: 1) SLI (Service Level Indicator): Gerçek zamanlı ölçülen metrik (ör. Başarılı HTTP isteklerinin yüzdesi). 2) SLO (Service Level Objective): Mühendislik ekibinin kendine koyduğu iç hedef (ör. Ayda %99.95 başarı). 3) SLA (Service Level Agreement): Müşteriye verilen yasal ve finansal taahhüt (ör. %99.9'un altına düşerse para iadesi). Hata Bütçesi (Error Budget): SLO'nuz %99.9 ise, %0.1'lik hata bütçeniz vardır. Bu bütçe tükenirse yeni özellik dağıtımları durdurulur ve sadece stabilite çalışılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[The trifecta of Site Reliability Engineering: 1) SLI (Service Level Indicator): The empirical, real-time metric (e.g., successful request ratio over 30 days). 2) SLO (Service Level Objective): The internal target committed by the engineering team (e.g., 99.95% availability). 3) SLA (Service Level Agreement): The legally binding contractual commitment to paying clients with penalty credits. Error Budget: If your SLO is 99.9%, you have an error budget of 0.1%. When the error budget burns, feature deployments freeze in favor of reliability engineering.]
    ]
  )
]

#java25_box[
```java
// Java 25: SLA & Hata Bütçesi (Error Budget) Hesaplama Motoru
public record AvailabilityCalculator(double availabilityPercentage) {
    private static final long SECONDS_IN_YEAR = 365L * 24 * 3600;

    public double calculateAnnualDowntimeSeconds() {
        double failureRate = (100.0 - availabilityPercentage) / 100.0;
        return SECONDS_IN_YEAR * failureRate;
    }

    public String formatDowntime() {
        long totalSecs = (long) calculateAnnualDowntimeSeconds();
        long hours = totalSecs / 3600;
        long mins = (totalSecs % 3600) / 60;
        long secs = totalSecs % 60;
        return hours + " sa " + mins + " dk " + secs + " sn";
    }
}

void main() {
    var fourNines = new AvailabilityCalculator(99.99);
    IO.println("99.99% Yıllık Maksimum Kesinti: " + fourNines.formatDowntime());
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
      Mülakatçınıza 'Sistemim %100 ayakta kalacak' demeyin! Dağıtık sistemlerde %100 kullanılabilirlik fiziksel olarak imkansızdır (ağ kabloları kopar, veri merkezleri su basar). %99.99 (Four Nines) gerçekçi kurumsal altın standarttır.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never claim 100% availability in a system design interview. 100% is mathematically impossible across distributed networks. Stating 99.99% demonstrates architectural maturity.]
    ]
  )
]

#takeaways_box((
    ("SLI neyi ölçtüğünüz, SLO hedefiniz, SLA ise müşteriye verdiğiniz yasal sözdür.", "SLI is the metric, SLO is the internal goal, SLA is the contractual penalty threshold."),
    ("99.99% (Dört Dokuz) yılda 52 dakikadan az kesinti demektir.", "Four Nines (99.99%) permits less than 52.6 minutes of downtime per year."),
    ("Hata bütçesi (Error Budget), inovasyon hızı ile sistem stabilitesi arasındaki dengeyi sağlar.", "Error budgets balance release velocity against platform stability."),
))
