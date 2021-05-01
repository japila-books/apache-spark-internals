# ShuffleExecutorComponents

`ShuffleExecutorComponents` is an [abstraction](#contract) of [executor shuffle builders](#implementations).

## Contract

### <span id="createMapOutputWriter"> createMapOutputWriter

```java
ShuffleMapOutputWriter createMapOutputWriter(
  int shuffleId,
  long mapTaskId,
  int numPartitions) throws IOException
```

Creates a [ShuffleMapOutputWriter](ShuffleMapOutputWriter.md)

Used when:

* `BypassMergeSortShuffleWriter` is requested to [write records](BypassMergeSortShuffleWriter.md#write)
* `UnsafeShuffleWriter` is requested to [mergeSpills](UnsafeShuffleWriter.md#mergeSpills) and [mergeSpillsUsingStandardWriter](UnsafeShuffleWriter.md#mergeSpillsUsingStandardWriter)
* `SortShuffleWriter` is requested to [write records](SortShuffleWriter.md#write)

### <span id="createSingleFileMapOutputWriter"> createSingleFileMapOutputWriter

```java
Optional<SingleSpillShuffleMapOutputWriter> createSingleFileMapOutputWriter(
  int shuffleId,
  long mapId) throws IOException
```

Creates a [SingleSpillShuffleMapOutputWriter](SingleSpillShuffleMapOutputWriter.md)

Default: empty

Used when:

* `UnsafeShuffleWriter` is requested to [mergeSpills](UnsafeShuffleWriter.md#mergeSpills)

### <span id="initializeExecutor"> initializeExecutor

```java
void initializeExecutor(
  String appId,
  String execId,
  Map<String, String> extraConfigs);
```

Used when:

* `SortShuffleManager` utility is used to [loadShuffleExecutorComponents](SortShuffleManager.md#loadShuffleExecutorComponents)

## Implementations

* [LocalDiskShuffleExecutorComponents](LocalDiskShuffleExecutorComponents.md)
