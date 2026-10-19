// Java 25: O(1) Çift Yönlü Bağlı Liste ve HashMap ile LRU Cache (En Eski Veriyi Silme)
// Compact Main ve Generic Tipler ile Modern Mimari

import java.util.HashMap;
import java.util.Map;

public class LruCache<K, V> {
    private static class Node<K, V> {
        K key;
        V value;
        Node<K, V> prev;
        Node<K, V> next;

        Node(K key, V value) {
            this.key = key;
            this.value = value;
        }
    }

    private final int capacity;
    private final Map<K, Node<K, V>> map;
    private final Node<K, V> head;
    private final Node<K, V> tail;

    public LruCache(int capacity) {
        this.capacity = capacity;
        this.map = new HashMap<>();
        this.head = new Node<>(null, null);
        this.tail = new Node<>(null, null);
        head.next = tail;
        tail.prev = head;
    }

    public synchronized V get(K key) {
        Node<K, V> node = map.get(key);
        if (node == null) return null;
        moveToHead(node);
        return node.value;
    }

    public synchronized void put(K key, V value) {
        Node<K, V> node = map.get(key);
        if (node != null) {
            node.value = value;
            moveToHead(node);
        } else {
            if (map.size() >= capacity) {
                Node<K, V> lru = tail.prev;
                removeNode(lru);
                map.remove(lru.key);
            }
            Node<K, V> newNode = new Node<>(key, value);
            map.put(key, newNode);
            addToHead(newNode);
        }
    }

    private void removeNode(Node<K, V> node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }

    private void addToHead(Node<K, V> node) {
        node.next = head.next;
        node.next.prev = node;
        node.prev = head;
        head.next = node;
    }

    private void moveToHead(Node<K, V> node) {
        removeNode(node);
        addToHead(node);
    }
}

// Java 25 Main Metodu
void main() {
    System.out.println("=== Java 25 O(1) LRU Cache Testi ===");
    var cache = new LruCache<String, Integer>(3);

    cache.put("A", 100);
    cache.put("B", 200);
    cache.put("C", 300);
    System.out.println("İlk eklemeler tamam (A, B, C). Kapasite: 3");

    System.out.println("A okundu: " + cache.get("A")); // A en başa geçti

    System.out.println("D eklendi (400) ──▶ En eski B silinmeli!");
    cache.put("D", 400);

    System.out.println("B'yi kontrol et (Silinmiş olmalı): " + cache.get("B")); // null
    System.out.println("A'yı kontrol et (Var olmalı): " + cache.get("A"));        // 100
    System.out.println("C'yi kontrol et (Var olmalı): " + cache.get("C"));        // 300
    System.out.println("D'yi kontrol et (Var olmalı): " + cache.get("D"));        // 400
}
