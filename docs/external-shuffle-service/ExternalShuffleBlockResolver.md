# ExternalShuffleBlockResolver

## Creating Instance

`ExternalShuffleBlockResolver` takes the following to be created:

* <span id="conf"> [TransportConf](../network/TransportConf.md)
* <span id="registeredExecutorFile"> `registeredExecutor` File (Java's [File]({{ java.api }}/java.base/java/io/File.html))
* [Directory Cleaner](#directoryCleaner)

`ExternalShuffleBlockResolver` is created when:

* `ExternalBlockHandler` is [created](ExternalBlockHandler.md#blockManager)

## <span id="directoryCleaner"> Directory Cleaner Executor

`ExternalShuffleBlockResolver` can be given a Java [Executor]({{ java.api }}/java.base/java/util/concurrent/Executor.html) or use a single worker thread executor (with **spark-shuffle-directory-cleaner** thread prefix).

## Logging

Enable `ALL` logging level for `org.apache.spark.network.shuffle.ExternalShuffleBlockResolver` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.shuffle.ExternalShuffleBlockResolver=ALL
```

Refer to [Logging](../spark-logging.md).

## Others

== [[getBlockData]] getBlockData Method

[source, java]
----
ManagedBuffer getBlockData(
  String appId,
  String execId,
  String blockId)
----

getBlockData parses `blockId` (in the format of `shuffle_[shuffleId]\_[mapId]_[reduceId]`) and returns the `FileSegmentManagedBuffer` that corresponds to `shuffle_[shuffleId]_[mapId]_0.data`.

getBlockData splits `blockId` to 4 parts using `_` (underscore). It works exclusively with `shuffle` block ids with the other three parts being `shuffleId`, `mapId`, and `reduceId`.

It looks up an executor (i.e. a `ExecutorShuffleInfo` in `executors` private registry) for `appId` and `execId` to search for a storage:BlockDataManager.md#ManagedBuffer[ManagedBuffer].

The `ManagedBuffer` is indexed using a binary file `shuffle_[shuffleId]\_[mapId]_0.index` (that contains offset and length of the buffer) with a data file being `shuffle_[shuffleId]_[mapId]_0.data` (that is returned as `FileSegmentManagedBuffer`).

It throws a `IllegalArgumentException` for block ids with less than four parts:

```
Unexpected block id format: [blockId]
```

or for non-`shuffle` block ids:

```
Expected shuffle block id, got: [blockId]
```

It throws a `RuntimeException` when no `ExecutorShuffleInfo` could be found.

```
Executor is not registered (appId=[appId], execId=[execId])"
```
