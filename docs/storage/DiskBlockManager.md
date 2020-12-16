# DiskBlockManager

`DiskBlockManager` manages a logical mapping of logical blocks and their physical on-disk locations for a [BlockManager](BlockManager.md#diskBlockManager).

![DiskBlockManager and BlockManager](../images/storage/DiskBlockManager-BlockManager.png)

By default, one block is mapped to one file with a name given by its `BlockId`. It is however possible to have a block map to only a segment of a file.

Block files are hashed among the [local directories](#getConfiguredLocalDirs).

`DiskBlockManager` is used to create a [DiskStore](DiskStore.md).

!!! tip
    Consult [Demo: DiskBlockManager and Block Data](../demo/diskblockmanager-and-block-data.md).

## Creating Instance

`DiskBlockManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="deleteFilesOnStop"> `deleteFilesOnStop` flag

When created, `DiskBlockManager` [creates one or many local directories to store block data](#localDirs) and initializes the internal [subDirs](#subDirs) collection of locks for every local directory.

In the end, `DiskBlockManager` [registers a shutdown hook](#addShutdownHook) to clean up the local directories for blocks.

`DiskBlockManager` is created for [BlockManager](BlockManager.md#diskBlockManager).

## <span id="localDirs"> Local Directories for Blocks

```scala
localDirs: Array[File]
```

While being created, `DiskBlockManager` [creates local directories](#createLocalDirs) for block data. `DiskBlockManager` expects at least one local directory or prints out the following ERROR message to the logs and exits the JVM (with exit code 53):

```text
Failed to create any local dir.
```

`localDirs` is used when:

* `DiskBlockManager` is requested to [getFile](#getFile), initialize the [subDirs](#subDirs) internal registry, and to [doStop](#doStop)
* `BlockManager` is requested to [register with an external shuffle server](BlockManager.md#registerWithExternalShuffleServer)

### <span id="createLocalDirs"> Creating Local Directories

```scala
createLocalDirs(
  conf: SparkConf): Array[File]
```

`createLocalDirs` creates `blockmgr-[random UUID]` directory under local directories to store block data.

Internally, `createLocalDirs` [finds the configured local directories where Spark can write files](#getConfiguredLocalDirs) and creates a subdirectory `blockmgr-[UUID]` under every configured parent directory.

For every local directory, `createLocalDirs` prints out the following INFO message to the logs:

```text
Created local directory at [localDir]
```

In case of an exception, `createLocalDirs` prints out the following ERROR message to the logs and skips the directory:

```text
Failed to create local dir in [rootDir]. Ignoring this directory.
```

## <span id="subDirsPerLocalDir"><span id="subDirs"> File Locks for Local Block Store Directories

```scala
subDirs: Array[Array[File]]
```

`subDirs` is a lookup table for file locks of every [local block directory](#localDirs) (with the first dimension for local directories and the second for locks).

The number of block subdirectories is controlled by [spark.diskStore.subDirectories](../configuration-properties.md#spark.diskStore.subDirectories) configuration property.

`subDirs(dirId)(subDirId)` is used to access `subDirId` subdirectory in `dirId` local directory.

`subDirs` is used when `DiskBlockManager` is requested for a [block file](#getFile) or [all block files](#getAllFiles).

## <span id="getFile"> Finding Block File (and Creating Parent Directories)

```scala
getFile(
  blockId: BlockId): File
getFile(
  filename: String): File
```

`getFile` computes a hash of the file name of the input [BlockId](BlockId.md) that is used for the name of the parent directory and subdirectory.

`getFile` creates the subdirectory unless it already exists.

`getFile` is used when:

* `DiskBlockManager` is requested to [containsBlock](#containsBlock), [createTempLocalBlock](#createTempLocalBlock), [createTempShuffleBlock](#createTempShuffleBlock)

* `DiskStore` is requested to [getBytes](DiskStore.md#getBytes), [remove](DiskStore.md#remove), [contains](DiskStore.md#contains), and [put](DiskStore.md#put)

* `IndexShuffleBlockResolver` is requested to [getDataFile](../shuffle/IndexShuffleBlockResolver.md#getDataFile) and [getIndexFile](../shuffle/IndexShuffleBlockResolver.md#getIndexFile)

## <span id="createTempShuffleBlock"> createTempShuffleBlock

```scala
createTempShuffleBlock(): (TempShuffleBlockId, File)
```

`createTempShuffleBlock` creates a temporary `TempShuffleBlockId` block.

`createTempShuffleBlock`...FIXME

## <span id="addShutdownHook"> Registering Shutdown Hook

```scala
addShutdownHook(): AnyRef
```

`addShutdownHook` registers a shutdown hook to execute [doStop](#doStop) at shutdown.

When executed, you should see the following DEBUG message in the logs:

```text
Adding shutdown hook
```

`addShutdownHook` adds the shutdown hook so it prints the following INFO message and executes [doStop](#doStop):

```text
Shutdown hook called
```

## <span id="getConfiguredLocalDirs"> Getting Local Directories for Spark to Write Files

```scala
getConfiguredLocalDirs(
  conf: SparkConf): Array[String]
```

`getConfiguredLocalDirs` returns the local directories where Spark can write files.

Internally, `getConfiguredLocalDirs` uses `conf` [SparkConf](../SparkConf.md) to know if [External Shuffle Service](../external-shuffle-service/ExternalShuffleService.md) is enabled (based on [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property).

`getConfiguredLocalDirs` checks if [Spark runs on YARN](#isRunningInYarnContainer) and if so, returns [LOCAL_DIRS](#getYarnLocalDirs)-controlled local directories.

In non-YARN mode (or for the driver in yarn-client mode), `getConfiguredLocalDirs` checks the following environment variables (in the order) and returns the value of the first met:

1. `SPARK_EXECUTOR_DIRS` environment variable
2. `SPARK_LOCAL_DIRS` environment variable
3. `MESOS_DIRECTORY` environment variable (only when External Shuffle Service is not used)

In the end, when no earlier environment variables were found, `getConfiguredLocalDirs` uses [spark.local.dir](../configuration-properties.md#spark.local.dir) configuration property or falls back to `java.io.tmpdir` System property.

`getConfiguredLocalDirs` is used when:

* `DiskBlockManager` is requested to [createLocalDirs](#createLocalDirs)
* `Utils` helper is requested to [getLocalDir](../Utils.md#getLocalDir) and [getOrCreateLocalRootDirsImpl](../Utils.md#getOrCreateLocalRootDirsImpl)

## <span id="getYarnLocalDirs"> Getting Writable Directories in YARN

```scala
getYarnLocalDirs(
  conf: SparkConf): String
```

`getYarnLocalDirs` uses `conf` [SparkConf](../SparkConf.md) to read `LOCAL_DIRS` environment variable with comma-separated local directories (that have already been created and secured so that only the user has access to them).

`getYarnLocalDirs` throws an `Exception` when `LOCAL_DIRS` environment variable was not set:

```text
Yarn Local dirs can't be empty
```

## <span id="isRunningInYarnContainer"> Checking Whether Spark Runs on YARN

```scala
isRunningInYarnContainer(
  conf: SparkConf): Boolean
```

`isRunningInYarnContainer` uses `conf` [SparkConf](../SparkConf.md) to read Hadoop YARN's [CONTAINER_ID]({{ hadoop.doc }}/hadoop-yarn/hadoop-yarn-api/apidocs/org/apache/hadoop/yarn/api/ApplicationConstants.Environment.html#CONTAINER_ID) environment variable to find out if Spark runs in a YARN container (that is exported by YARN NodeManager).

## <span id="getAllBlocks"> Getting All Blocks (From Files Stored On Disk)

```scala
getAllBlocks(): Seq[BlockId]
```

`getAllBlocks` gets all the blocks stored on disk.

Internally, `getAllBlocks` takes the [block files](#getAllFiles) and returns their names (as `BlockId`).

`getAllBlocks` is used when `BlockManager` is requested to [find IDs of existing blocks for a given filter](BlockManager.md#getMatchingBlockIds).

### <span id="getAllFiles"> All Block Files

```scala
getAllFiles(): Seq[File]
```

`getAllFiles`...FIXME

## <span id="stop"> Stopping

```scala
stop(): Unit
```

`stop`...FIXME

`stop` is used when `BlockManager` is requested to [stop](BlockManager.md#stop).

## <span id="doStop"> Stopping DiskBlockManager (Removing Local Directories for Blocks)

```scala
doStop(): Unit
```

`doStop` deletes the local directories recursively (only when the constructor's `deleteFilesOnStop` is enabled and the parent directories are not registered to be removed at shutdown).

`doStop` is used when `DiskBlockManager` is requested to [shut down](#addShutdownHook) or [stop](#stop).

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.DiskBlockManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.DiskBlockManager=ALL
```

Refer to [Logging](../spark-logging.md).
