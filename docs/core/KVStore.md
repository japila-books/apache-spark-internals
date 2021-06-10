# KVStore

`KVStore` is an [abstraction](#contract) of [key-value stores](#implementations).

`KVStore` is a Java [Closeable]({{ java.api }}/java.base/java/io/Closeable.html).

## Contract

### <span id="count"> count

```java
long count(
  Class<?> type)
long count(
  Class<?> type,
  String index,
  Object indexedValue)
```

### <span id="delete"> delete

```java
void delete(
  Class<?> type,
  Object naturalKey)
```

### <span id="getMetadata"> getMetadata

```java
<T> T getMetadata(
  Class<T> klass)
```

### <span id="read"> read

```java
<T> T read(
  Class<T> klass,
  Object naturalKey)
```

### <span id="removeAllByIndexValues"> removeAllByIndexValues

```java
<T> boolean removeAllByIndexValues(
  Class<T> klass,
  String index,
  Collection<?> indexValues)
```

### <span id="setMetadata"> setMetadata

```java
void setMetadata(
  Object value)
```

### <span id="view"> view

```java
<T> KVStoreView<T> view(
  Class<T> type)
```

`KVStoreView` over entities of the given `type`

### <span id="write"> write

```java
void write(
  Object value)
```

## Implementations

* [ElementTrackingStore](../status/ElementTrackingStore.md)
* [InMemoryStore](InMemoryStore.md)
* [LevelDB](LevelDB.md)
