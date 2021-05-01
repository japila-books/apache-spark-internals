# ShuffleDataIO

`ShuffleDataIO` is an [abstraction](#contract) of pluggable [temporary shuffle block store plugins](#implementations) for storing shuffle blocks in arbitrary storage backends.

## Contract

### <span id="driver"> ShuffleDriverComponents

```java
ShuffleDriverComponents driver()
```

Used when:

* `SparkContext` is [created](../SparkContext.md#shuffleDriverComponents)

### <span id="executor"> ShuffleExecutorComponents

```java
ShuffleExecutorComponents executor()
```

Used when:

* `SortShuffleManager` utility is used to [load the ShuffleExecutorComponents](SortShuffleManager.md#loadShuffleExecutorComponents)

## Implementations

* [LocalDiskShuffleDataIO](LocalDiskShuffleDataIO.md)
