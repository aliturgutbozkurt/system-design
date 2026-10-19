// Java 25: Consistent Hash Ring with Virtual Nodes (Sanal Düğümler)
// Dağıtık önbellek ve NoSQL veritabanı parça yönlendirmesi

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

public class ConsistentHashRing<T> {
    private final int numberOfReplicas; // Vnode sayısı
    private final SortedMap<Integer, T> circle = new TreeMap<>();

    public ConsistentHashRing(int numberOfReplicas, Collection<T> nodes) {
        this.numberOfReplicas = numberOfReplicas;
        for (T node : nodes) {
            addNode(node);
        }
    }

    public synchronized void addNode(T node) {
        for (int i = 0; i < numberOfReplicas; i++) {
            circle.put(hash(node.toString() + "#VN#" + i), node);
        }
    }

    public synchronized void removeNode(T node) {
        for (int i = 0; i < numberOfReplicas; i++) {
            circle.remove(hash(node.toString() + "#VN#" + i));
        }
    }

    public T get(Object key) {
        if (circle.isEmpty()) return null;
        int hash = hash(key.toString());
        if (!circle.containsKey(hash)) {
            SortedMap<Integer, T> tailMap = circle.tailMap(hash);
            hash = tailMap.isEmpty() ? circle.firstKey() : tailMap.firstKey();
        }
        return circle.get(hash);
    }

    private int hash(String key) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(key.getBytes(StandardCharsets.UTF_8));
            return ((digest[3] & 0xFF) << 24) | ((digest[2] & 0xFF) << 16) |
                   ((digest[1] & 0xFF) << 8) | (digest[0] & 0xFF);
        } catch (NoSuchAlgorithmException e) {
            return key.hashCode();
        }
    }
}

// Java 25 Main Metodu
void main() {
    System.out.println("=== Java 25 Consistent Hashing Ring Testi ===");
    var ring = new ConsistentHashRing<String>(100, List.of("Redis-Node-1", "Redis-Node-2", "Redis-Node-3"));

    List<String> userKeys = List.of("user:101:profile", "user:402:cart", "user:908:orders", "user:772:session");
    for (String key : userKeys) {
        System.out.println("Anahtar: " + key + " ──▶ Eşleşen Sunucu: " + ring.get(key));
    }

    System.out.println("\n--- Yeni Sunucu Eklendi: Redis-Node-4 ---");
    ring.addNode("Redis-Node-4");
    for (String key : userKeys) {
        System.out.println("Anahtar: " + key + " ──▶ Eşleşen Sunucu: " + ring.get(key));
    }
}
