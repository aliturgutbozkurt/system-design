// ==============================================================================
// MAANG SYSTEM DESIGN ELI5 - PROFESSIONAL TYPST TEMPLATE (v0.15+ COMPATIBLE)
// Çift Dilli (Türkçe & English) - Yayın Kalitesinde Kitap ve Ders Şablonu
// ==============================================================================

#let setup_book(title: "", author: "Antigravity & MAANG Architecture Guild", body) = {
  set document(title: title, author: author)
  set text(font: ("Avenir Next", "Helvetica Neue", "Arial"), size: 9.5pt, lang: "tr")
  set page(
    paper: "a4",
    margin: (x: 1.8cm, top: 2.2cm, bottom: 2.2cm),
    header: context {
      let cur_page = counter(page).get().first()
      if cur_page > 2 [
        #text(size: 8pt, fill: rgb("64748b"))[
          #grid(
            columns: (1fr, 1fr),
            [MAANG System Design: Zero to Staff+ Handbook],
            [#align(right)[Aptala Anlatır Gibi Sistem Tasarımı]]
          )
        ]
        #v(-2pt)
        #line(length: 100%, stroke: 0.5pt + rgb("e2e8f0"))
      ]
    },
    footer: context {
      let cur_page = counter(page).get().first()
      if cur_page > 2 [
        #line(length: 100%, stroke: 0.5pt + rgb("e2e8f0"))
        #v(2pt)
        #text(size: 8pt, fill: rgb("64748b"))[
          #grid(
            columns: (1fr, 1fr),
            [High-Scale Architecture & Java 25 Blueprint],
            [#align(right)[Sayfa / Page #counter(page).display()]]
          )
        ]
      ]
    }
  )
  set par(justify: true, leading: 0.6em)
  body
}

#let diagram_box(body) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("090d16"), // deep cyber dark
    stroke: (left: 4.5pt + rgb("06b6d4"), rest: 0.5pt + rgb("1e293b")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("38bdf8"), size: 10pt)[📐 Sistem Mimarisi & Veri Akış Şeması]],
        [#align(right)[#text(weight: "bold", fill: rgb("06b6d4"), size: 10pt)[📐 Architecture & Data Flow Diagram]]]
      )
      #v(4pt)
      #body
    ]
  )
  v(5pt)
}

#let eli5_box(body) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("eff6ff"), // soft blue
    stroke: (left: 4.5pt + rgb("2563eb"), rest: 0.5pt + rgb("bfdbfe")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("1e40af"), size: 10pt)[💡 Aptala Anlatım (ELI5 Metaforu)]],
        [#align(right)[#text(weight: "bold", fill: rgb("1d4ed8"), size: 10pt)[💡 ELI5 Metaphor]]]
      )
      #v(5pt)
      #body
    ]
  )
  v(5pt)
}

#let deep_dive_box(body) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("f8fafc"), // slate
    stroke: (left: 4.5pt + rgb("4f46e5"), rest: 0.5pt + rgb("cbd5e1")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("3730a3"), size: 10pt)[🔍 MAANG Seviyesi Teknik Derinlik]],
        [#align(right)[#text(weight: "bold", fill: rgb("4338ca"), size: 10pt)[🔍 MAANG-Level Technical Deep-Dive]]]
      )
      #v(5pt)
      #body
    ]
  )
  v(5pt)
}

#let java25_box(body) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("faf5ff"), // light violet
    stroke: (left: 4.5pt + rgb("9333ea"), rest: 0.5pt + rgb("e9d5ff")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("6b21a8"), size: 10pt)[⚡ Modern Java 25 Uygulaması (Loom & Records)]],
        [#align(right)[#text(weight: "bold", fill: rgb("7e22ce"), size: 10pt)[⚡ Java 25 Implementation]]]
      )
      #v(5pt)
      #body
    ]
  )
  v(5pt)
}

#let warning_box(body) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("fffbeb"), // amber
    stroke: (left: 4.5pt + rgb("d97706"), rest: 0.5pt + rgb("fde68a")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("b45309"), size: 10pt)[⚠️ Mülakat Tuzağı & Darboğaz Uyarısı]],
        [#align(right)[#text(weight: "bold", fill: rgb("92400e"), size: 10pt)[⚠️ Interview Trap & Bottleneck Alert]]]
      )
      #v(5pt)
      #body
    ]
  )
  v(5pt)
}

#let takeaways_box(takeaways) = {
  v(5pt)
  rect(
    width: 100%,
    fill: rgb("f0fdf4"), // emerald
    stroke: (left: 4.5pt + rgb("16a34a"), rest: 0.5pt + rgb("bbf7d0")),
    radius: (right: 6pt),
    inset: (x: 12pt, y: 10pt),
    [
      #grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        [#text(weight: "bold", fill: rgb("15803d"), size: 10pt)[🎯 Mülakatta Hatırlanacak Altın Çıkarımlar]],
        [#align(right)[#text(weight: "bold", fill: rgb("166534"), size: 10pt)[🎯 Key Takeaways for the Interview]]]
      )
      #v(5pt)
      #for item in takeaways [
        #grid(
          columns: (1fr, 1fr),
          gutter: 12pt,
          [#text(size: 8.5pt)[• #item.at(0)]],
          [#text(size: 8.5pt, fill: rgb("475569"))[• #item.at(1)]]
        )
        #v(2.5pt)
      ]
    ]
  )
  v(5pt)
}

#let lesson_header(lesson_num, title_tr, title_en, module_name_tr, module_name_en) = {
  v(4pt)
  rect(
    width: 100%,
    fill: rgb("0a0f1d"), // dark navy
    radius: 8pt,
    inset: (x: 14pt, y: 12pt),
    [
      #grid(
        columns: (auto, 1fr),
        gutter: 12pt,
        [
          #circle(radius: 18pt, fill: rgb("4f46e5"))[ // Indigo badge
            #align(center + horizon)[#text(weight: "bold", fill: white, size: 12pt)[#lesson_num]]
          ]
        ],
        [
          #text(size: 7.5pt, fill: rgb("a5b4fc"), weight: "bold")[
            BÖLÜM: #upper(module_name_tr)  |  MODULE: #upper(module_name_en)
          ]
          #v(2pt)
          #text(size: 12.5pt, fill: white, weight: "bold")[#title_tr]
          #v(2pt)
          #text(size: 10.5pt, fill: rgb("38bdf8"), weight: "medium")[#title_en]
        ]
      )
    ]
  )
  v(6pt)
}

#let module_cover(module_num, title_tr, title_en, desc_tr, desc_en) = {
  pagebreak()
  v(25pt)
  align(center)[
    #rect(
      width: 100%,
      fill: rgb("0f172a"),
      radius: 12pt,
      inset: (x: 22pt, y: 28pt),
      [
        #text(size: 13pt, fill: rgb("818cf8"), weight: "bold")[BÖLÜM #module_num / MODULE #module_num]
        #v(8pt)
        #text(size: 20pt, fill: white, weight: "bold")[#title_tr]
        #v(5pt)
        #text(size: 15pt, fill: rgb("94a3b8"), weight: "medium")[#title_en]
        #v(14pt)
        #line(length: 60%, stroke: 1.5pt + rgb("6366f1"))
        #v(14pt)
        #grid(
          columns: (1fr, 1fr),
          gutter: 18pt,
          [
            #align(left)[
              #text(size: 9.5pt, fill: rgb("cbd5e1"))[#desc_tr]
            ]
          ],
          [
            #align(left)[
              #text(size: 9.5pt, fill: rgb("94a3b8"))[#desc_en]
            ]
          ]
        )
      ]
    )
  ]
  v(18pt)
}

#let book_front_cover() = {
  set page(header: none, footer: none, margin: 0pt)
  rect(
    width: 100%,
    height: 100%,
    fill: rgb("060a14"), // ultimate midnight obsidian
    inset: (x: 3.2cm, y: 3.2cm),
    [
      #v(20pt)
      #rect(fill: rgb("1e1b4b"), radius: 4pt, inset: (x: 10pt, y: 6pt))[
        #text(size: 9.5pt, fill: rgb("a5b4fc"), weight: "bold")[MAANG / FAANG SYSTEM DESIGN MASTERY SUITE (BILINGUAL)]
      ]
      #v(16pt)
      #text(size: 32pt, fill: white, weight: "bold")[
        Aptala Anlatır Gibi\ Sistem Tasarımı
      ]
      #v(8pt)
      #text(size: 18pt, fill: rgb("818cf8"), weight: "medium")[
        Explain Like I'm 5: MAANG System Design Interview Masterclass
      ]
      #v(12pt)
      #text(size: 11.5pt, fill: rgb("94a3b8"))[
        10 Bölüm • 60 Ders • Mimari Şemalar • Java 25 (Loom) • Sıfırdan Staff+ Seviyeye
      ]
      #v(24pt)
      #line(length: 100%, stroke: 2pt + rgb("6366f1"))
      #v(24pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        gutter: 12pt,
        [
          #rect(fill: rgb("0f172a"), radius: 6pt, inset: 10pt, width: 100%)[
            #text(weight: "bold", fill: white, size: 9.5pt)[🏛️ Temel Yapı Taşları]\
            #v(2pt)
            #text(size: 8pt, fill: rgb("94a3b8"))[L4/L7 LB, Rate Limiting, Cache-Aside, Sharding, Consistent Hashing, LSM-Trees]
          ]
        ],
        [
          #rect(fill: rgb("0f172a"), radius: 6pt, inset: 10pt, width: 100%)[
            #text(weight: "bold", fill: white, size: 9.5pt)[⚡ Dağıtık Sistemler]\
            #v(2pt)
            #text(size: 8pt, fill: rgb("94a3b8"))[Raft Consensus, Kafka Streams, Snowflake IDs, Saga vs 2PC, Circuit Breaker]
          ]
        ],
        [
          #rect(fill: rgb("0f172a"), radius: 6pt, inset: 10pt, width: 100%)[
            #text(weight: "bold", fill: white, size: 9.5pt)[🎯 MAANG Vaka Çalışmaları]\
            #v(2pt)
            #text(size: 8pt, fill: rgb("94a3b8"))[TinyURL, WhatsApp, NewsFeed, YouTube, Uber H3, Stripe Payments & Staff+ Tradeoffs]
          ]
        ]
      )
      #v(40pt)
      #align(bottom)[
        #text(size: 9pt, fill: rgb("64748b"))[
          Yayın Sürümü: 1.0.0 • Java 25 & Modern Cloud Architecture • 2026
        ]
      ]
    ]
  )
}
