// Java 25: Twitter Snowflake 64-Bit Benzersiz ID Üretici
// 1 bit unused + 41 bit timestamp + 10 bit workerId + 12 bit sequence

public class SnowflakeIdGenerator {
    private static final long EPOCH = 1704067200000L; // 1 Ocak 2024 Özel Epoch
    private static final long WORKER_ID_BITS = 10L;
    private static final long SEQUENCE_BITS = 12L;

    private static final long MAX_WORKER_ID = ~(-1L << WORKER_ID_BITS); // 1023
    private static final long SEQUENCE_MASK = ~(-1L << SEQUENCE_BITS);   // 4095

    private static final long WORKER_ID_SHIFT = SEQUENCE_BITS;
    private static final long TIMESTAMP_LEFT_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS;

    private final long workerId;
    private long sequence = 0L;
    private long lastTimestamp = -1L;

    public SnowflakeIdGenerator(long workerId) {
        if (workerId > MAX_WORKER_ID || workerId < 0) {
            throw new IllegalArgumentException("Worker ID 0 ile " + MAX_WORKER_ID + " arasında olmalıdır.");
        }
        this.workerId = workerId;
    }

    public synchronized long nextId() {
        long timestamp = System.currentTimeMillis();

        if (timestamp < lastTimestamp) {
            throw new IllegalStateException("Clock drift tespit edildi! Saat geriye kaydı.");
        }

        if (lastTimestamp == timestamp) {
            sequence = (sequence + 1) & SEQUENCE_MASK;
            if (sequence == 0) {
                // Aynı milisaniyede 4096 sınırına ulaşıldı, sonraki milisaniyeyi bekle
                timestamp = waitNextMillis(lastTimestamp);
            }
        } else {
            sequence = 0L;
        }

        lastTimestamp = timestamp;

        return ((timestamp - EPOCH) << TIMESTAMP_LEFT_SHIFT)
                | (workerId << WORKER_ID_SHIFT)
                | sequence;
    }

    private long waitNextMillis(long lastTimestamp) {
        long timestamp = System.currentTimeMillis();
        while (timestamp <= lastTimestamp) {
            timestamp = System.currentTimeMillis();
        }
        return timestamp;
    }
}

// Java 25 Main Metodu
void main() {
    System.out.println("=== Java 25 Twitter Snowflake 64-Bit ID Testi ===");
    var generator = new SnowflakeIdGenerator(7); // Node #7

    for (int i = 1; i <= 5; i++) {
        long id = generator.nextId();
        System.out.println("Üretilen 64-bit ID #" + i + ": " + id + " (Binary: " + Long.toBinaryString(id) + ")");
    }
}
