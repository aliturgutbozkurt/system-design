#import "/template.typ": *

#show: doc => setup_book(title: "Bölüm 5: Asenkron İletişim, Mesajlaşma ve Olay Tabanlı Mimari", doc)

#module_cover(
  5,
  "Asenkron İletişim, Mesajlaşma ve Olay Tabanlı Mimari",
  "Asynchronous Messaging & Event-Driven Architecture",
  "Zamansal ayrışma, RabbitMQ vs Apache Kafka, Kafka partition ve consumer grupları, Exactly-Once garantileri, Idempotency ve Transactional Outbox deseni.",
  "Temporal decoupling, RabbitMQ vs Apache Kafka, Kafka commit logs & consumer groups, Exactly-Once semantics, Idempotency tokens, and the Transactional Outbox pattern."
)

#include "lesson_25.typ"
#v(16pt)

#include "lesson_26.typ"
#v(16pt)

#include "lesson_27.typ"
#v(16pt)

#include "lesson_28.typ"
#v(16pt)

#include "lesson_29.typ"
#v(16pt)

#include "lesson_30.typ"
#v(16pt)

