#import "/template.typ": *

#show: doc => setup_book(title: "Ders 46: Dosya Depolama ve Senkronizasyon (Google Drive / Dropbox): Chunking ve Sync", doc)

#lesson_header(
  46,
  "Dosya Depolama ve Senkronizasyon (Google Drive / Dropbox): Chunking ve Sync",
  "Designing Cloud Storage (Google Drive / Dropbox): Chunking & Sync",
  "Klasik MAANG Tasarım Problemleri - Bölüm 2",
  "Classic MAANG System Designs - Part 2"
)

#diagram_box[
```text
   [ GOOGLE DRIVE / DROPBOX BLOK DÜZEYİNDE SENKRONİZASYON (BLOCK CHUNKING) ]

   Orijinal Dosya (4 MB):  [ Blok 1 (1MB) ] [ Blok 2 (1MB) ] [ Blok 3 (1MB) ] [ Blok 4 (1MB) ]
                                                │ (Kullanıcı bu blokta 1 kelime değiştirdi!)
                                                ▼
   Güncellenmiş Dosya:     [ Blok 1 ]       [ Blok 2-YENİ ]    [ Blok 3 ]       [ Blok 4 ]
                              │                   │                │                │
                              ▼                   ▼                ▼                ▼
   S3'e Gönderilen:       (Gönderilmez!)    ──▶ YALNIZCA ──▶ (Gönderilmez!)   (Gönderilmez!)
                                            Blok 2-YENİ Gönderilir! (Bant genişliği %75 tasarruf!)
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\
      #v(3pt)
      100 sayfalık kalın bir kitap üzerinde çalıştığınızı düşünün. 52. sayfada tek bir harf hatasını düzelttiğinizde koca kitabı matbaaya gönderip 100 sayfayı baştan bastırmazsınız; sadece 52. sayfayı değiştirirsiniz! Dropbox ve Google Drive da böyle çalışır: 2 GB'lık bir video dosyasını 4 MB'lık yüzlerce bloğa (Chunk) böler. Dosyada tek bir satır değiştiğinde 2 GB'ı baştan yüklemez; sadece değişen o 4 MB'lık küçük bloğu bulur ve buluta fırlatır (Delta Sync). İnternet kotanız ve zamanınız kurtulur!
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\
      #v(3pt)
      #text(fill: rgb("334155"))[Editing a single typo on page 52 of a 500-page book doesn't require incinerating the entire print run and re-printing all 500 pages; you replace page 52! Cloud storage providers like Dropbox and Google Drive partition large files into discrete 4MB chunks. When you modify one sentence in a 1GB file, the desktop sync engine calculates cryptographic hashes across all chunks, identifies the single mutated block, and uploads only that 4MB delta! Bandwidth consumption drops by 99%!]
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
      MAANG Dosya Depolama Mimarisi: 1) Blok Düzeyinde Bölme (Chunking): Dosyalar 4 MB'lık bloklara bölünür. Her bloğun SHA-256 hash'i alınır. 2) Küresel Tekilleştirme (Cross-User Deduplication): Eğer Ahmet ve Mehmet aynı 1 GB'lık Ubuntu ISO dosyasını yüklüyorsa, sistem blok hash'lerine bakar. Bloklar zaten S3'te varsa İKİNCİ KEZ YÜKLENMEZ; sadece veritabanında referans pointer'ı açılır. Milyonlarca dolar depolama ve ağ tasarrufu sağlanır. 3) Senkronizasyon Çakışması (Sync Conflict): İki kullanıcı çevrimdışı aynı dosyayı düzenleyip aynı anda bağlanırsa ne olur? Git tarzı versiyon çakışması üretilir: 'Dosya (Ali's conflicted copy)' şeklinde yeni bir dosya dallandırılır.
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\
      #v(3pt)
      #text(fill: rgb("334155"))[MAANG Cloud Storage & Sync Architecture: 1) Block-Level Chunking: Files split into fixed (4MB) or variable-length (Rabin fingerprinting) chunks. Each block generates a unique cryptographic SHA-256 hash. 2) Cross-User Deduplication: If 10,000 corporate employees save the same 500MB PDF presentation, block hashing detects matching fingerprints in S3; the storage cluster skips the upload entirely and increments metadata reference pointers, saving petabytes of storage. 3) Delta Sync Engine: Local sync daemons monitor file system watch events, compute modified block diffs, and upload strictly modified chunks. 4) Conflict Resolution: Concurrent offline mutations are resolved by branching diverging file trees ('Project Plan (Alice's conflicted copy)').]
    ]
  )
]

#java25_box[
```java
// Java 25: Blok Düzeyinde SHA-256 Hash Hesaplama ve Tekilleştirme Simülasyonu
import java.security.MessageDigest;
import java.util.*;

public class BlockDeduplicationEngine {
    private final Set<String> cloudBlockStorage = new HashSet<>();

    public String computeBlockHash(byte[] blockBytes) throws Exception {
        var md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest(blockBytes);
        return HexFormat.of().formatHex(digest).substring(0, 12); // Kısaltılmış hash
    }

    public boolean uploadBlockIfMissing(String blockHash) {
        // Blok zaten S3'te varsa YÜKLEME! (Deduplication)
        return cloudBlockStorage.add(blockHash);
    }
}

void main() throws Exception {
    var engine = new BlockDeduplicationEngine();
    byte[] chunk1 = "Ders Notu Parça 1".getBytes();
    String hash1 = engine.computeBlockHash(chunk1);

    IO.println("Blok 1 Yüklendi mi (İlk Kez)? " + engine.uploadBlockIfMissing(hash1));
    IO.println("Blok 1 Yüklendi mi (Tekrar)?  " + engine.uploadBlockIfMissing(hash1) + " (Deduplication Devrede!)");
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
      Mülakatta 'Dosyaları tek parça halinde yüklerim' demeyin! 5 GB'lık bir dosya yüklenirken %99'da internet koparsa tüm dosya çöpe gider. Blok tabanlı yüklemede (Chunking) sadece kopan 4 MB'lık blok yeniden denenir (Resumable Upload).
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\
      #v(3pt)
      #text(fill: rgb("78350f"))[Never pitch uploading monolithic multi-gigabyte files in single HTTP streams. If connectivity drops at 99%, the entire upload fails. Chunking guarantees resumable uploads where only the interrupted 4MB block re-transmits.]
    ]
  )
]

#takeaways_box((
    ("Dosyaları 4MB'lık bloklara bölmek yalnızca değişen kısımların yüklenmesini (Delta Sync) sağlar.", "Chunking files into 4MB blocks enables delta sync, uploading only modified bytes."),
    ("Blok hash'leri sayesinde aynı dosya bulutta tek bir kez saklanır (Cross-User Deduplication).", "Cross-user deduplication detects identical block hashes, eliminating petabytes of duplicate S3 data."),
    ("Kopan yüklemeler baştan başlamaz; yalnızca eksik kalan bloklar kaldığı yerden devam eder.", "Chunked uploads enable robust resumable uploads after network disconnects."),
))
