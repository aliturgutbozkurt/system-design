#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_all.py
Master generator and compiler for the 10-Module, 60-Lesson Bilingual ELI5
MAANG System Design Masterclass (Bilingual TR & EN with Java 25 & Architecture Diagrams).

Outputs:
  - content/module_XX/lesson_YY.typ (60 files)
  - content/module_XX/module_XX.typ (10 files)
  - book.typ (Master unified book)
  - output/individual/lesson_XX.pdf (60 PDFs)
  - output/modules/module_XX.pdf (10 PDFs)
  - output/book/System_Design_MAANG_ELI5.pdf (1 Master Mega-PDF)
  - web/data/lessons.json (Structured JSON for Web Companion Reader)
  - web/data/lessons.js (Offline window.LESSONS_DATA bundle)
"""

import os
import sys
import json
import subprocess
from pathlib import Path

BASE_DIR = Path("/Users/aliturgutbozkurt/Desktop/system-design")
MODULES_DATA_DIR = BASE_DIR / "modules_data"
CONTENT_DIR = BASE_DIR / "content"
OUTPUT_DIR = BASE_DIR / "output"
WEB_DIR = BASE_DIR / "web"

sys.path.insert(0, str(MODULES_DATA_DIR))
import mod01_fundamentals
import mod02_load_balancing
import mod03_caching_cdn
import mod04_databases_sharding
import mod05_async_messaging
import mod06_distributed_systems
import mod07_classic_systems_part1
import mod08_classic_systems_part2
import mod09_advanced_systems
import mod10_interview_mastery

MODULES = [
    mod01_fundamentals.MODULE,
    mod02_load_balancing.MODULE,
    mod03_caching_cdn.MODULE,
    mod04_databases_sharding.MODULE,
    mod05_async_messaging.MODULE,
    mod06_distributed_systems.MODULE,
    mod07_classic_systems_part1.MODULE,
    mod08_classic_systems_part2.MODULE,
    mod09_advanced_systems.MODULE,
    mod10_interview_mastery.MODULE,
]

import re

def sanitize_typst_text(s: str) -> str:
    """Escapes dollar signs, <, @, and braces to prevent math mode, labels, references, or code blocks."""
    if not s:
        return ""
    s = s.replace("$", "\\$")
    s = re.sub(r"(?<!\\)<", r"\<", s)
    s = re.sub(r"(?<!\\)@", r"\@", s)
    s = re.sub(r"(?<!\\)\{", r"\{", s)
    s = re.sub(r"(?<!\\)\}", r"\}", s)
    return s

def generate_lesson_typ(m: dict, l: dict) -> str:
    takeaways_typ = ""
    for item in l.get('takeaways', []):
        tr_item = sanitize_typst_text(item[0]).replace('"', '\\"')
        en_item = sanitize_typst_text(item[1]).replace('"', '\\"')
        takeaways_typ += f'    ("{tr_item}", "{en_item}"),\n'

    eli5_tr = sanitize_typst_text(l['eli5_tr'])
    eli5_en = sanitize_typst_text(l['eli5_en'])
    deep_tr = sanitize_typst_text(l['deep_tr'])
    deep_en = sanitize_typst_text(l['deep_en'])
    warning_tr = sanitize_typst_text(l['warning_tr'])
    warning_en = sanitize_typst_text(l['warning_en'])

    content = f'''#import "/template.typ": *

#show: doc => setup_book(title: "Ders {l['num']}: {l['title_tr']}", doc)

#lesson_header(
  {l['num']},
  "{l['title_tr']}",
  "{l['title_en']}",
  "{m['title_tr']}",
  "{m['title_en']}"
)

#diagram_box[
```text
{l['diagram']}
```
]

#eli5_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("1e40af"), size: 9pt)[🇹🇷 TÜRKÇE (ELI5)]\\
      #v(3pt)
      {eli5_tr}
    ],
    [
      #text(weight: "bold", fill: rgb("1d4ed8"), size: 9pt)[🇬🇧 ENGLISH (ELI5)]\\
      #v(3pt)
      #text(fill: rgb("334155"))[{eli5_en}]
    ]
  )
]

#deep_dive_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("334155"), size: 9pt)[🇹🇷 MAANG DERİNLEMESİNE ANALİZ]\\
      #v(3pt)
      {deep_tr}
    ],
    [
      #text(weight: "bold", fill: rgb("475569"), size: 9pt)[🇬🇧 MAANG TECHNICAL DEEP-DIVE]\\
      #v(3pt)
      #text(fill: rgb("334155"))[{deep_en}]
    ]
  )
]

#java25_box[
```java
{l['java_code']}
```
]

#warning_box[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      #text(weight: "bold", fill: rgb("b45309"), size: 9pt)[🇹🇷 MÜLAKAT TUZAĞI VE DARBOĞAZ]\\
      #v(3pt)
      {warning_tr}
    ],
    [
      #text(weight: "bold", fill: rgb("92400e"), size: 9pt)[🇬🇧 INTERVIEW TRAP & BOTTLENECK]\\
      #v(3pt)
      #text(fill: rgb("78350f"))[{warning_en}]
    ]
  )
]

#takeaways_box((
{takeaways_typ}))
'''
    return content

def generate_module_typ(m: dict) -> str:
    desc_tr = sanitize_typst_text(m['desc_tr']).replace('"', '\\"')
    desc_en = sanitize_typst_text(m['desc_en']).replace('"', '\\"')
    title_tr = m['title_tr'].replace('"', '\\"')
    title_en = m['title_en'].replace('"', '\\"')

    content = f'''#import "/template.typ": *

#show: doc => setup_book(title: "Bölüm {m['id']}: {title_tr}", doc)

#module_cover(
  {m['id']},
  "{title_tr}",
  "{title_en}",
  "{desc_tr}",
  "{desc_en}"
)

'''
    for l in m['lessons']:
        filename = f"lesson_{l['num']:02d}.typ"
        content += f'#include "{filename}"\n#v(16pt)\n\n'
    return content

def generate_master_book_typ() -> str:
    content = '''#import "/template.typ": *

#show: doc => setup_book(
  title: "Aptala Anlatır Gibi MAANG Sistem Tasarımı El Kitabı",
  author: "Antigravity & MAANG Architecture Guild",
  doc
)

#book_front_cover()

#pagebreak()
#v(20pt)
#align(center)[
  #text(size: 20pt, weight: "bold", fill: rgb("0f172a"))[Önsöz ve Başlarken / Preface & Getting Started]
]
#v(16pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,
  [
    == 🇹🇷 Bu Eğitim Hakkında
    Bu kitap; Meta, Amazon, Apple, Netflix, Google (MAANG) ve benzeri birinci sınıf teknoloji şirketlerinin Sistem Tasarımı (System Design) mülakatlarına hazırlanan yazılım mühendisleri ve mimarlar için özel olarak hazırlanmıştır.

    En karmaşık dağıtık sistem mimarileri (Consistent Hashing, LSM-Trees, Raft Consensus, Kafka Partitions, Gorilla TSDB, H3 Uber Geohashing, Snowflake IDs, Saga Pattern vb.) *bir aptala anlatır gibi* en yalın analojiler, mimari ASCII akış şemaları ve modern *Java 25 (Loom, Virtual Threads, Records, IO)* kodlarıyla ele alınmıştır.

    60 derslik bu müfredat, sizi junior bir geliştiriciden milyonlarca eşzamanlı isteği ve petabaytlarca veriyi sakinlikle yöneten bir *Staff+ Principal Architect* zihniyetine ulaştırmayı hedefler.
  ],
  [
    == 🇬🇧 About This Masterclass
    This masterclass is meticulously engineered for software engineers, tech leads, and aspiring architects preparing for high-stakes System Design rounds at Tier-1 companies (MAANG / FAANG).

    We demystify high-concurrency distributed systems—ranging from Consistent Hashing and Raft Consensus to Kafka Event Streams, TSDB compression, and Geo-distributed Ledgers—using crystal-clear *Explain Like I'm 5 (ELI5)* metaphors, architectural schematics, and clean *Java 25* implementations (featuring Project Loom Virtual Threads, pattern matching, and concise records).

    Over 60 progressive lessons grouped into 10 structured modules, this curriculum transforms abstract theoretical knowledge into decisive Staff+ architectural leadership.
  ]
)

#v(20pt)
#line(length: 100%, stroke: 0.8pt + rgb("e2e8f0"))
#v(10pt)

#outline(
  title: [İçindekiler / Table of Contents],
  depth: 2,
  indent: auto
)

#pagebreak()
'''
    for m in MODULES:
        desc_tr = sanitize_typst_text(m['desc_tr']).replace('"', '\\"')
        desc_en = sanitize_typst_text(m['desc_en']).replace('"', '\\"')
        title_tr = m['title_tr'].replace('"', '\\"')
        title_en = m['title_en'].replace('"', '\\"')
        content += f'''
#module_cover(
  {m['id']},
  "{title_tr}",
  "{title_en}",
  "{desc_tr}",
  "{desc_en}"
)

'''
        for l in m['lessons']:
            rel_path = f"/content/{m['dir']}/lesson_{l['num']:02d}.typ"
            content += f'#include "{rel_path}"\n#v(14pt)\n\n'

    content += '''
#pagebreak()
#v(40pt)
#align(center)[
  #rect(fill: rgb("0f172a"), radius: 10pt, inset: (x: 24pt, y: 32pt), width: 90%)[
    #text(size: 24pt, fill: rgb("38bdf8"), weight: "bold")[🎓 TEBRİKLER! / CONGRATULATIONS!]\
    #v(10pt)
    #text(size: 14pt, fill: white)[60 Derslik MAANG Sistem Tasarımı Yolculuğunu Başarıyla Tamamladınız!]\
    #v(6pt)
    #text(size: 11pt, fill: rgb("94a3b8"))[You have successfully conquered all 60 lessons of the MAANG System Design Masterclass!]\
    #v(20pt)
    #line(length: 60%, stroke: 1pt + rgb("4f46e5"))
    #v(15pt)
    #text(size: 10pt, fill: rgb("cbd5e1"))[
      Architecture Schematics • Java 25 Virtual Threads • Distributed Consensus • Staff+ Trade-Offs
    ]
  ]
]
'''
    return content

def generate_web_json():
    data = {
        "title_tr": "Aptala Anlatır Gibi MAANG Sistem Tasarımı",
        "title_en": "Explain Like I'm 5: MAANG System Design Masterclass",
        "description": "60 Ders • 10 Bölüm • Çift Dilli (TR & EN) • Mimari Şemalar • Java 25",
        "modules": MODULES
    }
    web_data_dir = WEB_DIR / "data"
    web_data_dir.mkdir(parents=True, exist_ok=True)
    with open(web_data_dir / "lessons.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    with open(web_data_dir / "lessons.js", "w", encoding="utf-8") as f:
        f.write("window.LESSONS_DATA = " + json.dumps(data, ensure_ascii=False) + ";\n")
    print(f"✔ Exported web data to {web_data_dir / 'lessons.json'} and lessons.js")

def write_all_typst_files():
    CONTENT_DIR.mkdir(parents=True, exist_ok=True)
    for m in MODULES:
        mod_dir = CONTENT_DIR / m['dir']
        mod_dir.mkdir(parents=True, exist_ok=True)
        for l in m['lessons']:
            lesson_typ = generate_lesson_typ(m, l)
            lesson_path = mod_dir / f"lesson_{l['num']:02d}.typ"
            with open(lesson_path, "w", encoding="utf-8") as f:
                f.write(lesson_typ)
        
        module_typ = generate_module_typ(m)
        module_path = mod_dir / f"module_{m['id']:02d}.typ"
        with open(module_path, "w", encoding="utf-8") as f:
            f.write(module_typ)
    
    book_typ = generate_master_book_typ()
    with open(BASE_DIR / "book.typ", "w", encoding="utf-8") as f:
        f.write(book_typ)
    print("✔ All Typst source files generated successfully!")

def compile_typst(src: Path, out: Path) -> bool:
    out.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "typst", "compile",
        "--root", str(BASE_DIR),
        str(src),
        str(out)
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"❌ Error compiling {src.name}: {res.stderr}")
        return False
    return True

def compile_all_pdfs():
    (OUTPUT_DIR / "individual").mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "modules").mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "book").mkdir(parents=True, exist_ok=True)

    print("\n--- 1. Compiling Master Book PDF ---")
    book_src = BASE_DIR / "book.typ"
    book_out = OUTPUT_DIR / "book" / "System_Design_MAANG_ELI5.pdf"
    if compile_typst(book_src, book_out):
        size_kb = book_out.stat().st_size / 1024
        print(f"✔ Master Book PDF created: {book_out.name} ({size_kb:.1f} KB)")

    print("\n--- 2. Compiling 10 Module PDFs ---")
    for m in MODULES:
        mod_src = CONTENT_DIR / m['dir'] / f"module_{m['id']:02d}.typ"
        mod_out = OUTPUT_DIR / "modules" / f"module_{m['id']:02d}_{m['dir']}.pdf"
        if compile_typst(mod_src, mod_out):
            size_kb = mod_out.stat().st_size / 1024
            print(f"✔ Module {m['id']} PDF: {mod_out.name} ({size_kb:.1f} KB)")

    print("\n--- 3. Compiling 60 Individual Lesson PDFs ---")
    success_count = 0
    for m in MODULES:
        for l in m['lessons']:
            les_src = CONTENT_DIR / m['dir'] / f"lesson_{l['num']:02d}.typ"
            les_out = OUTPUT_DIR / "individual" / f"lesson_{l['num']:02d}.pdf"
            if compile_typst(les_src, les_out):
                success_count += 1
            else:
                print(f"Failed lesson {l['num']}")
    print(f"✔ Compiled {success_count}/60 Individual Lesson PDFs successfully!")

if __name__ == "__main__":
    print("🚀 Starting Complete Curriculum Generation...")
    write_all_typst_files()
    generate_web_json()

    mode = sys.argv[1] if len(sys.argv) > 1 else "--all"
    if mode == "--all":
        compile_all_pdfs()
    elif mode == "--book":
        book_src = BASE_DIR / "book.typ"
        book_out = OUTPUT_DIR / "book" / "System_Design_MAANG_ELI5.pdf"
        compile_typst(book_src, book_out)
    elif mode == "--modules":
        for m in MODULES:
            mod_src = CONTENT_DIR / m['dir'] / f"module_{m['id']:02d}.typ"
            mod_out = OUTPUT_DIR / "modules" / f"module_{m['id']:02d}_{m['dir']}.pdf"
            compile_typst(mod_src, mod_out)
    elif mode == "--json-only":
        pass
