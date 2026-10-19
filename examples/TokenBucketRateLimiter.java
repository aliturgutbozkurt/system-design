// Java 25: Token Bucket Algoritması ile Dağıtık Hız Sınırlayıcı (Rate Limiter)
// Modern Java 25 Compact Main & Virtual Thread Friendly

import java.util.concurrent.atomic.AtomicLong;

public class TokenBucketRateLimiter {
    private final long capacity;
    private final double refillTokensPerSecond;
    private final AtomicLong availableTokens;
    private final AtomicLong lastRefillTimestampNanos;

    public TokenBucketRateLimiter(long capacity, double refillTokensPerSecond) {
        this.capacity = capacity;
        this.refillTokensPerSecond = refillTokensPerSecond;
        this.availableTokens = new AtomicLong(capacity);
        this.lastRefillTimestampNanos = new AtomicLong(System.nanoTime());
    }

    public synchronized boolean tryAcquire(long tokensToConsume) {
        refill();
        long current = availableTokens.get();
        if (current >= tokensToConsume) {
            availableTokens.addAndGet(-tokensToConsume);
            return true; // İstek onaylandı
        }
        return false; // Hata 429: Too Many Requests
    }

    private void refill() {
        long now = System.nanoTime();
        long last = lastRefillTimestampNanos.get();
        double elapsedSeconds = (now - last) / 1_000_000_000.0;
        if (elapsedSeconds > 0) {
            long tokensToAdd = (long) (elapsedSeconds * refillTokensPerSecond);
            if (tokensToAdd > 0) {
                long current = availableTokens.get();
                long newTokens = Math.min(capacity, current + tokensToAdd);
                availableTokens.set(newTokens);
                lastRefillTimestampNanos.set(now);
            }
        }
    }

    public long getAvailableTokens() {
        return availableTokens.get();
    }
}

// Java 25 Launch Entry Point
void main() {
    // 5 istek kapasiteli kova, saniyede 2 jeton yenilenir
    var limiter = new TokenBucketRateLimiter(5, 2.0);

    System.out.println("=== Java 25 Token Bucket Rate Limiter Testi ===");
    for (int i = 1; i <= 7; i++) {
        boolean allowed = limiter.tryAcquire(1);
        System.out.println("İstek #" + i + " Sonuç: " + (allowed ? "✅ 200 OK (Geçti)" : "❌ 429 Too Many Requests (Engellendi)") +
                           " | Kalan Jeton: " + limiter.getAvailableTokens());
    }
}
