#import "/template.typ": *

#show: doc => setup_book(title: "Bölüm 3: Önbellekleme Mimarisi ve CDN Stratejileri", doc)

#module_cover(
  3,
  "Önbellekleme Mimarisi ve CDN Stratejileri",
  "Distributed Caching Architectures & CDN Strategies",
  "Donanım gecikme piramidi, Cache-Aside vs Write-Through, LRU tahliye mekanizması, Redis Cluster, Cache Stampede/Avalanche felaketleri ve Kenar CDN mimarisi.",
  "Hardware latency hierarchy, Cache-Aside vs Write-Through, LRU evictions, Redis clustering, Thundering Herd mitigations, and Edge CDN deployment topologies."
)

#include "lesson_13.typ"
#v(16pt)

#include "lesson_14.typ"
#v(16pt)

#include "lesson_15.typ"
#v(16pt)

#include "lesson_16.typ"
#v(16pt)

#include "lesson_17.typ"
#v(16pt)

#include "lesson_18.typ"
#v(16pt)

