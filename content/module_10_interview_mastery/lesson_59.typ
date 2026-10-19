#import "/template.typ": *

#show: doc => setup_book(title: "Ders 59: Maliyet Optimizasyonu ve Bulut Ekonomisi (FinOps): Egress, Spot ve Tiering", doc)

#lesson_header(
  59,
  "Maliyet Optimizasyonu ve Bulut Ekonomisi (FinOps): Egress, Spot ve Tiering",
  "Cloud Economics & FinOps: Egress Costs, Spot Instances & Data Tiering",
  "Mülakat Ustalığı, Canlı Beyaz Tahta & Staff+ Seviyesi",
  "MAANG Interview Mastery, Whiteboarding & Staff+ Playbook"
)

#diagram_box[
```text
   [ BULUT MALİYET OPTİMİZASYON PİRAMİDİ (FINOPS STRATEJİSİ) ]

   1. AĞ MALİYETİ (EGRESS)     : İnternete veri çıkarmak ($0.09/GB) ÇOK PAHALIDIR!
                                 Çözüm: CDN önbellekleme ve sıkıştırma (Gzip/Brotli/ZSTD)
   2. HESAPLAMA (COMPUTE)      : Sürekli On-Demand makine çalıştırmak israftır!
                                 Çözüm: Spot/Preemptible makineler (%70-90 indirim!)
   3. VERİ SAKLAMA (STORAGE)   : Tüm veriyi pahalı SSD'de tutmak maliyet intiharıdır!
                                 Çözüm: Yaşam Döngüsü (Lifecycle Tiering): Hot -> Warm -> Glacier
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      Bir şirkette elektrik ve su faturalarını yönettiğinizi düşünün: 1) İnternet Çıkış Ücreti (Egress): Evinize su almak bedavadır ama dışarıya her kova su boşalttığınızda su idaresi sizden 10 TL para alır! Bulut sağlayıcıları da (AWS, Google Cloud) içeri veri alırken para almaz ama dışarıya çıkan her gigabayttan (Egress) servet kazanır. 2) Spot Makineler: Uçaktaki son dakika boş koltukları gibidir; havayolu koltuk boş gitmesin diye %80 indirimle satar! Siz de arka planda video kodlayan sunucuları bu indirimli Spot makinelerden seçersiniz. 3) Arşiv Depolama: 5 yıl önceki faturaları lüks bir gökdelende değil, şehir dışındaki ucuz bir depoda (AWS Glacier) saklamaktır!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Think of managing utility bills for a massive industrial complex: 1) Egress Bandwidth: Pumping water into your reservoir is free, but dumping water back into the city pipes incurs a \$10 penalty per bucket! Cloud providers (AWS, GCP) charge zero for data ingress, but levy eye-watering tolls on every gigabyte exiting their network (Egress). 2) Spot Instances: Standby standby airline tickets sold at an 80% discount 20 minutes before takeoff. Use Spot nodes for asynchronous video transcoding or batch training! 3) Storage Tiering: Storing 5-year-old tax audits inside expensive downtown prime real estate (NVMe SSD) is financial suicide; move them to a dusty underground warehouse in the desert (AWS Glacier)!]
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
      MAANG Seviyesi FinOps Mimarisi: 1) Egress Trafik Tuzağı: Bulutta bölgeler arası (Cross-Region) veya internete çıkan veri en pahalı kalemdir (\$0.08 - \$0.12 / GB). Çözüm: CDN kullanımıyla origin egress'ini %90 düşürmek, aynı kullanılabilirlik alanında (AZ) kalmak ve gRPC/Protobuf/ZSTD ile veriyi sıkıştırmak. 2) Spot / Preemptible Örnekler: AWS ve GCP'nin boşta duran kapasitesini %70-%90 indirimle sunmasıdır. Sağlayıcı makineyi 2 dakika önceden haber vererek geri alabilir. Durumsuz işçiler (Video Transcoding, ML eğitimi, Batch Job) için kusursuzdur. 3) S3 Yaşam Döngüsü (Lifecycle Tiering): S3 Standard (\$0.023/GB) -> S3 Infrequent Access (\$0.0125/GB) -> S3 Glacier Flexible (\$0.0036/GB) -> S3 Glacier Deep Archive (\$0.00099/GB). 90 günden eski loglar Glacier'a atılarak depolama maliyeti 23 kat düşürülür!
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG Cloud FinOps Disciplines: 1) The Egress Bandit: Cloud providers charge zero for inbound traffic, but penalize internet and cross-region egress with steep fees (\$0.08-\$0.12/GB). Solutions: Maximize CDN cache offloading, enforce colocation within identical Availability Zones, and mandate Protobuf with Zstandard compression. 2) Spot / Preemptible Fleet Arbitrage: Cloud vendors auction spare compute at 70%-90% discounts with a 2-minute preemption warning. Ideal for stateless, containerized worker pools (video transcoding, model inference, background queue drainers) orchestrated by Kubernetes Karpenter. 3) Object Storage Lifecycle Tiering: S3 Standard (\$0.023/GB) transitions automatically after 30 days to Infrequent Access (\$0.0125/GB), then after 90 days to Glacier Flexible (\$0.0036/GB), and finally to Glacier Deep Archive (\$0.00099/GB). Slashes cold storage expenditure by 95% while retaining compliance guarantees.]
    ]
  )
]

#java25_box[
```java
// Java 25: S3 Depolama Katmanlama (Tiering) Maliyet Karşılaştırma Modeli
public class FinOpsStorageCalculator {
    public static double calculateMonthlyCost(double terabytes, String tier) {
        double costPerGb = switch (tier) {
            case "S3_STANDARD"     -> 0.023;
            case "S3_INFREQUENT"   -> 0.0125;
            case "S3_GLACIER"      -> 0.0036;
            case "GLACIER_DEEP"    -> 0.00099;
            default                -> 0.023;
        };
        return (terabytes * 1024) * costPerGb;
    }
}

void main() {
    double tb = 100.0; // 100 Terabayt Veri
    double standardCost = FinOpsStorageCalculator.calculateMonthlyCost(tb, "S3_STANDARD");
    double deepArchiveCost = FinOpsStorageCalculator.calculateMonthlyCost(tb, "GLACIER_DEEP");

    IO.println("100 TB S3 Standard Aylık Maliyet:     $" + String.format("%.2f", standardCost));
    IO.println("100 TB Glacier Deep Aylık Maliyet:    $" + String.format("%.2f", deepArchiveCost));
    IO.println("Aylık Tasarruf Oranı: %" + String.format("%.1f", (1.0 - (deepArchiveCost / standardCost)) * 100));
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
      Mülakatta 'Maliyeti hiç düşünmem, her yere en pahalı AWS sunucularını ve 100 replika koyarım' demeyin! Staff ve Principal seviyesindeki mühendisler mimariyi sadece performans için değil, şirket bütçesini ve bulut maliyetlerini (Unit Economics) korumak için tasarlar.
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Dismissing cloud costs in an interview as 'someone else's problem' guarantees an L4 downgrade. Staff and Principal engineers distinguish themselves by anchoring technical architectures to cloud unit economics and FinOps efficiency.]
    ]
  )
]

#takeaways_box((
    ("Egress trafiği bulut faturalarının en tehlikeli ve gizli maliyet kalemidir.", "Network egress is the single most expensive hidden trap in cloud architecture."),
    ("Spot makineler durumsuz iş yüklerinde maliyetleri %80'e varan oranda düşürür.", "Spot compute instances deliver up to 80% cost savings for fault-tolerant background workloads."),
    ("Otomatik S3 Lifecycle kuralları soğuk verileri Glacier'a taşıyarak %95 tasarruf sağlar.", "S3 lifecycle tiering transitions cold historical logs into deep archive, saving 95%."),
))
