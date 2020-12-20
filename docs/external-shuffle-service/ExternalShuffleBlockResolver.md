# ExternalShuffleBlockResolver

`ExternalShuffleBlockResolver` manages converting shuffle [BlockId](../storage/BlockId.md)s into physical segments of local files (from a process outside of [Executor](../executor/Executor.md)s).

## Creating Instance

`ExternalShuffleBlockResolver` takes the following to be created:

* <span id="conf"> [TransportConf](../network/TransportConf.md)
* <span id="registeredExecutorFile"> `registeredExecutor` File (Java's [File]({{ java.api }}/java.base/java/io/File.html))
* [Directory Cleaner](#directoryCleaner)

`ExternalShuffleBlockResolver` is created when:

* `ExternalBlockHandler` is [created](ExternalBlockHandler.md#blockManager)

## <span id="executors"> Executors

`ExternalShuffleBlockResolver` uses a mapping of `ExecutorShuffleInfo`s by `AppExecId`.

`ExternalShuffleBlockResolver` can (re)load this mapping from a [registeredExecutor file](#registeredExecutorFile) or simply start from scratch.

A new mapping is added when [registering an executor](#registerExecutor).

## <span id="directoryCleaner"> Directory Cleaner Executor

`ExternalShuffleBlockResolver` can be given a Java [Executor]({{ java.api }}/java.base/java/util/concurrent/Executor.html) or use a single worker thread executor (with **spark-shuffle-directory-cleaner** thread prefix).

The `Executor` is used to schedule a thread to clean up [executor's local directories](#deleteExecutorDirs) and [non-shuffle and non-RDD files in executor's local directories](#deleteNonShuffleServiceServedFiles).

## <span id="rddFetchEnabled"> spark.shuffle.service.fetch.rdd.enabled

`ExternalShuffleBlockResolver` uses [spark.shuffle.service.fetch.rdd.enabled](configuration-properties.md#spark.shuffle.service.fetch.rdd.enabled) configuration property to [control whether or not to remove cached RDD files](#deleteNonShuffleServiceServedFiles) (alongside shuffle output files).

## <span id="registerExecutor"> Registering Executor

```java
void registerExecutor(
  String appId,
  String execId,
  ExecutorShuffleInfo executorInfo)
```

`registerExecutor`...FIXME

`registerExecutor` is used when:

* `ExternalBlockHandler` is requested to [handle a RegisterExecutor message](ExternalBlockHandler.md#RegisterExecutor) and [reregisterExecutor](ExternalBlockHandler.md#reregisterExecutor)

## <span id="executorRemoved"> Cleaning Up Local Directories for Removed Executor

```java
void executorRemoved(
  String executorId,
  String appId)
```

`executorRemoved` prints out the following INFO message to the logs:

```text
Clean up non-shuffle and non-RDD files associated with the finished executor [executorId]
```

`executorRemoved` looks up the executor in the [executors](#executors) internal registry.

When found, `executorRemoved` prints out the following INFO message to the logs and requests the [Directory Cleaner Executor](#directoryCleaner) to execute asynchronous [deletion](#deleteNonShuffleServiceServedFiles) of the executor's local directories (on a separate thread).

```text
Cleaning up non-shuffle and non-RDD files in executor [AppExecId]'s [localDirs] local dirs
```

When not found, `executorRemoved` prints out the following INFO message to the logs:

```text
Executor is not registered (appId=[appId], execId=[executorId])
```

`executorRemoved` is used when:

* `ExternalBlockHandler` is requested to [executorRemoved](ExternalBlockHandler.md#executorRemoved)

### <span id="deleteNonShuffleServiceServedFiles"> deleteNonShuffleServiceServedFiles

```java
void deleteNonShuffleServiceServedFiles(
  String[] dirs)
```

`deleteNonShuffleServiceServedFiles` creates a Java [FilenameFilter]({{ java.api }}/java.base/java/io/FilenameFilter.html) for files that meet all of the following:

1. A file name does not end with `.index` or `.data`
1. With [rddFetchEnabled](#rddFetchEnabled) is enabled, a file name does not start with `rdd_` prefix

`deleteNonShuffleServiceServedFiles` deletes files and directories (based on the `FilenameFilter`) in every directory (in the input `dirs`).

`deleteNonShuffleServiceServedFiles` prints out the following DEBUG message to the logs:

```text
Successfully cleaned up files not served by shuffle service in directory: [localDir]
```

In case of any exceptions, `deleteNonShuffleServiceServedFiles` prints out the following ERROR message to the logs:

```text
Failed to delete files not served by shuffle service in directory: [localDir]
```

## <span id="applicationRemoved"> Application Removed Notification

```java
void applicationRemoved(
  String appId,
  boolean cleanupLocalDirs)
```

`applicationRemoved`...FIXME

`applicationRemoved` is used when:

* `ExternalBlockHandler` is requested to [applicationRemoved](ExternalBlockHandler.md#applicationRemoved)

### <span id="deleteExecutorDirs"> deleteExecutorDirs

```java
void deleteExecutorDirs(
  String[] dirs)
```

`deleteExecutorDirs`...FIXME

## <span id="getBlockData"> Fetching Block Data

```java
ManagedBuffer getBlockData(
  String appId,
  String execId,
  int shuffleId,
  long mapId,
  int reduceId)
```

`getBlockData`...FIXME

`getBlockData` is used when:

* `ManagedBufferIterator` is created
* `ShuffleManagedBufferIterator` is requested for next [ManagedBuffer](../network/ManagedBuffer.md)

## Logging

Enable `ALL` logging level for `org.apache.spark.network.shuffle.ExternalShuffleBlockResolver` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.shuffle.ExternalShuffleBlockResolver=ALL
```

Refer to [Logging](../spark-logging.md).
