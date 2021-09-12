# Spark Configuration Properties

## <span id="spark.app.id"> spark.app.id

Unique identifier of a Spark application that Spark uses to uniquely identify [metric sources](metrics/MetricsSystem.md#buildRegistryName).

Default: [TaskScheduler.applicationId()](scheduler/TaskScheduler.md#applicationId)

Set when [SparkContext](SparkContext.md) is created

## <span id="spark.broadcast.blockSize"><span id="BROADCAST_BLOCKSIZE"> spark.broadcast.blockSize

The size of each piece of a block  (in kB unless the unit is specified)

Default: `4m`

Too large a value decreases parallelism during broadcast (makes it slower); however, if it is too small, BlockManager might take a performance hit

Used when:

* `TorrentBroadcast` is requested to [setConf](broadcast-variables/TorrentBroadcast.md#blockSize)

## <span id="spark.broadcast.compress"><span id="BROADCAST_COMPRESS"> spark.broadcast.compress

Controls broadcast variable compression (before sending them over the wire)

Default: `true`

Generally a good idea. Compression will use [spark.io.compression.codec](#spark.io.compression.codec)

Used when:

* `TorrentBroadcast` is requested to [setConf](broadcast-variables/TorrentBroadcast.md#compressionCodec)
* `SerializerManager` is [created](serializer/SerializerManager.md#compressBroadcast)

## <span id="spark.cleaner.referenceTracking"><span id="CLEANER_REFERENCE_TRACKING"> spark.cleaner.referenceTracking

Controls whether to enable [ContextCleaner](core/ContextCleaner.md)

Default: `true`

## <span id="spark.diskStore.subDirectories"><span id="DISKSTORE_SUB_DIRECTORIES"> spark.diskStore.subDirectories

Number of subdirectories inside each path listed in [spark.local.dir](#spark.local.dir) for hashing block files into.

Default: `64`

Used by [BlockManager](storage/BlockManager.md#subDirsPerLocalDir) and [DiskBlockManager](storage/DiskBlockManager.md#subDirsPerLocalDir)

## <span id="spark.driver.host"><span id="DRIVER_HOST_ADDRESS"> spark.driver.host

Address of the driver (endpoints)

Default: [Utils.localCanonicalHostName](Utils.md#localCanonicalHostName)

## <span id="spark.driver.maxResultSize"><span id="MAX_RESULT_SIZE"> spark.driver.maxResultSize

Maximum size of task results (in bytes)

Default: `1g`

Used when:

* `TaskRunner` is requested to [run a task](executor/TaskRunner.md#run) (and [decide on the type of a serialized task result](executor/TaskRunner.md#run-serializedResult))

* `TaskSetManager` is requested to [check available memory for task results](scheduler/TaskSetManager.md#canFetchMoreResults)

## <span id="spark.driver.port"><span id="DRIVER_PORT"> spark.driver.port

Port of the driver (endpoints)

Default: `0`

## <span id="spark.executor.cores"><span id="EXECUTOR_CORES"> spark.executor.cores

Number of CPU cores for [Executor](executor/Executor.md)

Default: `1`

## <span id="spark.executor.id"> spark.executor.id

Default: (undefined)

## <span id="spark.executor.memory"> spark.executor.memory

Amount of memory to use for an [Executor](executor/Executor.md#memory)

Default: `1g`

Equivalent to [SPARK_EXECUTOR_MEMORY](SparkContext.md#environment-variables) environment variable.

## <span id="spark.executor.metrics.fileSystemSchemes"><span id="EXECUTOR_METRICS_FILESYSTEM_SCHEMES"> spark.executor.metrics.fileSystemSchemes

A comma-separated list of the file system schemes to report in [executor metrics](executor/ExecutorSource.md#fileSystemSchemes)

Default: `file,hdfs`

## <span id="spark.extraListeners"> spark.extraListeners

A comma-separated list of fully-qualified class names of [SparkListener](SparkListener.md)s (to be registered when [SparkContext](SparkContext.md) is created)

Default: (empty)

## <span id="spark.file.transferTo"> spark.file.transferTo

Controls whether to use Java [FileChannel]({{ java.api }}/java.base/java/nio/channels/FileChannel.html)s (Java NIO) for copying data between two Java `FileInputStream`s to improve copy performance

Default: `true`

Used when:

* [BypassMergeSortShuffleWriter](shuffle/BypassMergeSortShuffleWriter.md#transferToEnabled) and [UnsafeShuffleWriter](shuffle/UnsafeShuffleWriter.md#transferToEnabled) are created

## <span id="spark.files"> spark.files

The files [to be added](SparkContext.md#addFile) to a Spark application (that can be defined directly as a configuration property or indirectly using `--files` option of `spark-submit` script)

Default: (empty)

Used when:

* `SparkContext` is [created](SparkContext-creating-instance-internals.md#files)

## <span id="spark.io.encryption.enabled"><span id="IO_ENCRYPTION_ENABLED"> spark.io.encryption.enabled

Controls local disk I/O encryption

Default: `false`

Used when:

* `SparkEnv` utility is used to [create a SparkEnv for the driver](SparkEnv.md#createDriverEnv) (to create a IO encryption key)
* `BlockStoreShuffleReader` is requested to [read combined records](shuffle/BlockStoreShuffleReader.md#read) (and [fetchContinuousBlocksInBatch](shuffle/BlockStoreShuffleReader.md#fetchContinuousBlocksInBatch))

## <span id="spark.jars"> spark.jars

Default: (empty)

## <span id="spark.kryo.pool"><span id="KRYO_USE_POOL"> spark.kryo.pool

Default: `true`

Used when:

* `KryoSerializer` is [created](serializer/KryoSerializer.md#usePool)

## <span id="spark.kryo.unsafe"><span id="KRYO_USE_UNSAFE"> spark.kryo.unsafe

Whether [KryoSerializer](serializer/KryoSerializer.md#useUnsafe) should use Unsafe-based IO for serialization

Default: `false`

## <span id="spark.local.dir"> spark.local.dir

A comma-separated list of directories that are used as a temporary storage for "scratch" space (incl. map output files and RDDs that get stored on disk). This should be on a fast, local disk in your system.

Default: `/tmp`

## <span id="spark.logConf"> spark.logConf

Default: `false`

## <span id="spark.logLineage"> spark.logLineage

Default: `false`

## <span id="spark.master"> spark.master

**Master URL** of the cluster manager to connect the Spark application to

## <span id="spark.memory.fraction"> spark.memory.fraction

Fraction of JVM heap space used for execution and storage.

Default: `0.6`

The lower the more frequent spills and cached data eviction. The purpose of this config is to set aside memory for internal metadata, user data structures, and imprecise size estimation in the case of sparse, unusually large records. Leaving this at the default value is recommended.

## <span id="spark.memory.offHeap.enabled"><span id="MEMORY_OFFHEAP_ENABLED"> spark.memory.offHeap.enabled

Controls whether Tungsten memory will be allocated on the JVM heap (`false`) or off-heap (`true` / using `sun.misc.Unsafe`).

Default: `false`

When enabled, [spark.memory.offHeap.size](#spark.memory.offHeap.size) must be [greater than 0](memory/MemoryManager.md#tungstenMemoryMode).

Used when:

* `MemoryManager` is requested for [tungstenMemoryMode](memory/MemoryManager.md#tungstenMemoryMode)

## <span id="spark.memory.offHeap.size"><span id="MEMORY_OFFHEAP_SIZE"> spark.memory.offHeap.size

Maximum memory (in bytes) for off-heap memory allocation

Default: `0`

This setting has no impact on heap memory usage, so if your executors' total memory consumption must fit within some hard limit then be sure to shrink your JVM heap size accordingly.

Must not be negative and be set to a positive value when [spark.memory.offHeap.enabled](#spark.memory.offHeap.enabled) is enabled

## <span id="spark.memory.storageFraction"><span id="MEMORY_STORAGE_FRACTION"> spark.memory.storageFraction

Amount of storage memory immune to eviction, expressed as a fraction of the size of the region set aside by [spark.memory.fraction](#spark.memory.fraction).

Default: `0.5`

The higher the less working memory may be available to execution and tasks may spill to disk more often. The default value is recommended.

Must be in `[0,1)`

Used when:

* `UnifiedMemoryManager` is [created](memory/UnifiedMemoryManager.md#apply)
* `MemoryManager` is [created](memory/MemoryManager.md#offHeapStorageMemory)

## <span id="spark.network.maxRemoteBlockSizeFetchToMem"><span id="MAX_REMOTE_BLOCK_SIZE_FETCH_TO_MEM"> spark.network.maxRemoteBlockSizeFetchToMem

Remote block will be fetched to disk when size of the block is above this threshold in bytes

This is to avoid a giant request takes too much memory. Note this configuration will affect both shuffle fetch and block manager remote block fetch.

With an external shuffle service use at least 2.3.0

Default: `200m`

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)
* `NettyBlockTransferService` is requested to [uploadBlock](storage/NettyBlockTransferService.md#uploadBlock)
* `BlockManager` is requested to [fetchRemoteManagedBuffer](storage/BlockManager.md#fetchRemoteManagedBuffer)

## <span id="spark.network.timeout"><span id="NETWORK_TIMEOUT"> spark.network.timeout

Network timeout (in seconds) to use for RPC remote endpoint lookup

Default: `120s`

## <span id="spark.network.timeoutInterval"><span id="NETWORK_TIMEOUT_INTERVAL"> spark.network.timeoutInterval

(in millis)

Default: [spark.storage.blockManagerTimeoutIntervalMs](#STORAGE_BLOCKMANAGER_TIMEOUTINTERVAL)

## <span id="spark.rdd.compress"> spark.rdd.compress

Controls whether to compress RDD partitions when stored serialized

Default: `false`

## <span id="spark.reducer.maxBlocksInFlightPerAddress"><span id="REDUCER_MAX_BLOCKS_IN_FLIGHT_PER_ADDRESS"> spark.reducer.maxBlocksInFlightPerAddress

Maximum number of remote blocks being fetched per reduce task from a given host port

When a large number of blocks are being requested from a given address in a single fetch or simultaneously, this could crash the serving executor or a Node Manager. This is especially useful to reduce the load on the Node Manager when external shuffle is enabled. You can mitigate the issue by setting it to a lower value.

Default: (unlimited)

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)

## <span id="spark.reducer.maxReqsInFlight"><span id="REDUCER_MAX_REQS_IN_FLIGHT"> spark.reducer.maxReqsInFlight

Maximum number of remote requests to fetch blocks at any given point

When the number of hosts in the cluster increase, it might lead to very large number of inbound connections to one or more nodes, causing the workers to fail under load. By allowing it to limit the number of fetch requests, this scenario can be mitigated

Default: (unlimited)

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)

## <span id="spark.reducer.maxSizeInFlight"><span id="REDUCER_MAX_SIZE_IN_FLIGHT"> spark.reducer.maxSizeInFlight

Maximum size of all map outputs to fetch simultaneously from each reduce task (in MiB unless otherwise specified)

Since each output requires us to create a buffer to receive it, this represents a fixed memory overhead per reduce task, so keep it small unless you have a large amount of memory

Default: `48m`

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)

## <span id="spark.repl.class.uri"> spark.repl.class.uri

Controls whether to compress RDD partitions when stored serialized

Default: `false`

## <span id="spark.rpc.lookupTimeout"> spark.rpc.lookupTimeout

[Default Endpoint Lookup Timeout](rpc/RpcEnv.md#defaultLookupTimeout)

Default: `120s`

## <span id="spark.rpc.message.maxSize"><span id="RPC_MESSAGE_MAX_SIZE"> spark.rpc.message.maxSize

Maximum allowed message size for RPC communication (in `MB` unless specified)

Default: `128`

Must be below [2047MB](rpc/RpcUtils.md#MAX_MESSAGE_SIZE_IN_MB) (`Int.MaxValue / 1024 / 1024`)

Used when:

* `CoarseGrainedSchedulerBackend` is requested to [launch tasks](scheduler/CoarseGrainedSchedulerBackend.md#launchTasks)
* `RpcUtils` is requested for the [maximum message size](rpc/RpcUtils.md#maxMessageSizeBytes)
    * `Executor` is [created](executor/Executor.md#maxDirectResultSize)
    * `MapOutputTrackerMaster` is [created](scheduler/MapOutputTrackerMaster.md#maxRpcMessageSize) (and makes sure that [spark.shuffle.mapOutput.minSizeForBroadcast](#spark.shuffle.mapOutput.minSizeForBroadcast) is below the threshold)

## <span id="spark.scheduler.minRegisteredResourcesRatio"> spark.scheduler.minRegisteredResourcesRatio

Minimum ratio of (registered resources / total expected resources) before submitting tasks

Default: (undefined)

## <span id="spark.scheduler.revive.interval"><span id="SCHEDULER_REVIVE_INTERVAL"> spark.scheduler.revive.interval

**Revive Interval** that is the time (in millis) between resource offers revives

Default: `1s`

Used when:

* `DriverEndpoint` is requested to [onStart](scheduler/DriverEndpoint.md#onStart)

## <span id="spark.serializer"> spark.serializer

The fully-qualified class name of the [Serializer](serializer/Serializer.md) (of the [driver and executors](SparkEnv.md#create))

Default: `org.apache.spark.serializer.JavaSerializer`

Used when:

* `SparkEnv` utility is used to [create a SparkEnv](SparkEnv.md#create)
* `SparkConf` is requested to [registerKryoClasses](SparkConf.md#registerKryoClasses) (as a side-effect)

## <span id="spark.shuffle.compress"> spark.shuffle.compress

Controls whether to compress shuffle output when stored

Default: `true`

## <span id="spark.shuffle.detectCorrupt"><span id="SHUFFLE_DETECT_CORRUPT"> spark.shuffle.detectCorrupt

Controls corruption detection in fetched blocks

Default: `true`

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)

## <span id="spark.shuffle.detectCorrupt.useExtraMemory"><span id="SHUFFLE_DETECT_CORRUPT_MEMORY"> spark.shuffle.detectCorrupt.useExtraMemory

If enabled, part of a compressed/encrypted stream will be de-compressed/de-crypted by using extra memory to detect early corruption. Any `IOException` thrown will cause the task to be retried once and if it fails again with same exception, then `FetchFailedException` will be thrown to retry previous stage

Default: `false`

Used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](shuffle/BlockStoreShuffleReader.md#read)

## <span id="spark.shuffle.file.buffer"> spark.shuffle.file.buffer

Size of the in-memory buffer for each shuffle file output stream, in KiB unless otherwise specified. These buffers reduce the number of disk seeks and system calls made in creating intermediate shuffle files.

Default: `32k`

Must be greater than `0` and less than or equal to `2097151` (`(Integer.MAX_VALUE - 15) / 1024`)

Used when the following are created:

* [BypassMergeSortShuffleWriter](shuffle/BypassMergeSortShuffleWriter.md)
* [ShuffleExternalSorter](shuffle/ShuffleExternalSorter.md)
* [UnsafeShuffleWriter](shuffle/UnsafeShuffleWriter.md)
* [ExternalAppendOnlyMap](shuffle/ExternalAppendOnlyMap.md)
* [ExternalSorter](shuffle/ExternalSorter.md)

## <span id="spark.shuffle.manager"> spark.shuffle.manager

A fully-qualified class name or the alias of the [ShuffleManager](shuffle/ShuffleManager.md) in a Spark application

Default: `sort`

Supported aliases:

* `sort`
* `tungsten-sort`

Used when `SparkEnv` object is requested to [create a "base" SparkEnv for a driver or an executor](SparkEnv.md#create)

## <span id="spark.shuffle.mapOutput.parallelAggregationThreshold"><span id="SHUFFLE_MAP_OUTPUT_PARALLEL_AGGREGATION_THRESHOLD"> spark.shuffle.mapOutput.parallelAggregationThreshold

**(internal)** Multi-thread is used when the number of mappers * shuffle partitions is greater than or equal to this threshold. Note that the actual parallelism is calculated by number of mappers * shuffle partitions / this threshold + 1, so this threshold should be positive.

Default: `10000000`

Used when:

* `MapOutputTrackerMaster` is requested for the [statistics of a ShuffleDependency](scheduler/MapOutputTrackerMaster.md#getStatistics)

## <span id="spark.shuffle.minNumPartitionsToHighlyCompress"><span id="SHUFFLE_MIN_NUM_PARTS_TO_HIGHLY_COMPRESS"> spark.shuffle.minNumPartitionsToHighlyCompress

**(internal)** Minimum number of partitions (threshold) for `MapStatus` utility to prefer a [HighlyCompressedMapStatus](scheduler/MapStatus.md#HighlyCompressedMapStatus) (over [CompressedMapStatus](scheduler/MapStatus.md#CompressedMapStatus)) (for [ShuffleWriters](shuffle/ShuffleWriter.md)).

Default: `2000`

Must be a positive integer (above `0`)

## <span id="spark.shuffle.readHostLocalDisk"><span id="SHUFFLE_HOST_LOCAL_DISK_READING_ENABLED"> spark.shuffle.readHostLocalDisk

If enabled (with [spark.shuffle.useOldFetchProtocol](#spark.shuffle.useOldFetchProtocol) disabled and [spark.shuffle.service.enabled](external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) enabled), shuffle blocks requested from those block managers which are running on the same host are read from the disk directly instead of being fetched as remote blocks over the network.

Default: `true`

## <span id="spark.shuffle.registration.maxAttempts"><span id="SHUFFLE_REGISTRATION_MAX_ATTEMPTS"> spark.shuffle.registration.maxAttempts

How many attempts to [register a BlockManager with External Shuffle Service](storage/BlockManager.md#registerWithExternalShuffleServer)

Default: `3`

Used when `BlockManager` is requested to [register with External Shuffle Server](storage/BlockManager.md#registerWithExternalShuffleServer)

## <span id="spark.shuffle.sort.bypassMergeThreshold"><span id="SHUFFLE_SORT_BYPASS_MERGE_THRESHOLD"> spark.shuffle.sort.bypassMergeThreshold

Maximum number of reduce partitions below which [SortShuffleManager](shuffle/SortShuffleManager.md) avoids merge-sorting data for no map-side aggregation

Default: `200`

Used when:

* `SortShuffleWriter` utility is used to [shouldBypassMergeSort](shuffle/SortShuffleWriter.md#shouldBypassMergeSort)
* `ShuffleExchangeExec` ([Spark SQL]({{ book.spark_sql }}/physical-operators/ShuffleExchangeExec)) physical operator is requested to `prepareShuffleDependency`

## <span id="spark.shuffle.sort.io.plugin.class"><span id="SHUFFLE_IO_PLUGIN_CLASS"> spark.shuffle.sort.io.plugin.class

Name of the class to use for [shuffle IO](shuffle/ShuffleDataIO.md)

Default: [LocalDiskShuffleDataIO](shuffle/LocalDiskShuffleDataIO.md)

## <span id="spark.shuffle.spill.initialMemoryThreshold"> spark.shuffle.spill.initialMemoryThreshold

Initial threshold for the size of an in-memory collection

Default: 5MB

Used by [Spillable](shuffle/Spillable.md#initialMemoryThreshold)

## <span id="spark.shuffle.spill.numElementsForceSpillThreshold"><span id="SHUFFLE_SPILL_NUM_ELEMENTS_FORCE_SPILL_THRESHOLD"> spark.shuffle.spill.numElementsForceSpillThreshold

**(internal)** The maximum number of elements in memory before forcing the shuffle sorter to spill.

Default: `Integer.MAX_VALUE`

The default value is to never force the sorter to spill, until Spark reaches some limitations, like the max page size limitation for the pointer array in the sorter.

Used when:

* [ShuffleExternalSorter](shuffle/ShuffleExternalSorter.md) is created
* [Spillable](shuffle/Spillable.md) is created
* Spark SQL's `SortBasedAggregator` is requested for an `UnsafeKVExternalSorter`
* Spark SQL's `ObjectAggregationMap` is requested to `dumpToExternalSorter`
* Spark SQL's `UnsafeExternalRowSorter` is created
* Spark SQL's `UnsafeFixedWidthAggregationMap` is requested for an `UnsafeKVExternalSorter`

## <span id="spark.shuffle.sync"><span id="SHUFFLE_SYNC"> spark.shuffle.sync

Controls whether `DiskBlockObjectWriter` should force outstanding writes to disk while [committing a single atomic block](storage/DiskBlockObjectWriter.md#commitAndGet) (i.e. all operating system buffers should synchronize with the disk to ensure that all changes to a file are in fact recorded in the storage)

Default: `false`

Used when `BlockManager` is requested for a [DiskBlockObjectWriter](storage/BlockManager.md#getDiskWriter)

## <span id="spark.shuffle.useOldFetchProtocol"><span id="SHUFFLE_USE_OLD_FETCH_PROTOCOL"> spark.shuffle.useOldFetchProtocol

Whether to use the old protocol while doing the shuffle block fetching. It is only enabled while we need the compatibility in the scenario of new Spark version job fetching shuffle blocks from old version external shuffle service.

Default: `false`

## <span id="spark.speculation"> spark.speculation

Controls [Speculative Execution of Tasks](speculative-execution-of-tasks.md)

Default: `false`

## <span id="spark.speculation.interval"> spark.speculation.interval

The time interval to use before checking for speculative tasks in [Speculative Execution of Tasks](speculative-execution-of-tasks.md).

Default: `100ms`

## <span id="spark.speculation.multiplier"> spark.speculation.multiplier

Default: `1.5`

## <span id="spark.speculation.quantile"> spark.speculation.quantile

The percentage of tasks that has not finished yet at which to start speculation in [Speculative Execution of Tasks](speculative-execution-of-tasks.md).

Default: `0.75`

## <span id="spark.storage.blockManagerSlaveTimeoutMs"><span id="STORAGE_BLOCKMANAGER_SLAVE_TIMEOUT"> spark.storage.blockManagerSlaveTimeoutMs

(in millis)

Default: [spark.network.timeout](#NETWORK_TIMEOUT)

## <span id="spark.storage.blockManagerTimeoutIntervalMs"><span id="STORAGE_BLOCKMANAGER_TIMEOUTINTERVAL"> spark.storage.blockManagerTimeoutIntervalMs

(in millis)

Default: `60s`

## <span id="spark.storage.localDiskByExecutors.cacheSize"><span id="STORAGE_LOCAL_DISK_BY_EXECUTORS_CACHE_SIZE"> spark.storage.localDiskByExecutors.cacheSize

The max number of executors for which the local dirs are stored. This size is both applied for the driver and both for the executors side to avoid having an unbounded store. This cache will be used to avoid the network in case of fetching disk persisted RDD blocks or shuffle blocks (when [spark.shuffle.readHostLocalDisk](#spark.shuffle.readHostLocalDisk) is set) from the same host.

Default: `1000`

## <span id="spark.storage.replication.policy"> spark.storage.replication.policy

Default: [RandomBlockReplicationPolicy](storage/RandomBlockReplicationPolicy.md)

## <span id="spark.storage.unrollMemoryThreshold"><span id="STORAGE_UNROLL_MEMORY_THRESHOLD"> spark.storage.unrollMemoryThreshold

Initial memory threshold (in bytes) to unroll (materialize) a block to store in memory

Default: `1024 * 1024`

Must be at most the [total amount of memory available for storage](storage/MemoryStore.md#maxMemory)

Used when:

* `MemoryStore` is [created](storage/MemoryStore.md#unrollMemoryThreshold)

## <span id="spark.task.cpus"><span id="CPUS_PER_TASK"> spark.task.cpus

The number of CPU cores to schedule (_allocate_) to a task

Default: `1`

Used when:

* `ExecutorAllocationManager` is [created](dynamic-allocation/ExecutorAllocationManager.md#tasksPerExecutorForFullParallelism)
* `TaskSchedulerImpl` is [created](scheduler/TaskSchedulerImpl.md#CPUS_PER_TASK)
* `AppStatusListener` is requested to [handle a SparkListenerEnvironmentUpdate event](status/AppStatusListener.md#onEnvironmentUpdate)
* `SparkContext` utility is used to [create a TaskScheduler](SparkContext.md#createTaskScheduler)
* `ResourceProfile` is requested to [getDefaultTaskResources](stage-level-scheduling/ResourceProfile.md#getDefaultTaskResources)
* `LocalityPreferredContainerPlacementStrategy` is requested to `numExecutorsPending`

## <span id="spark.task.maxDirectResultSize"><span id="TASK_MAX_DIRECT_RESULT_SIZE"> spark.task.maxDirectResultSize

Maximum size of a task result (in bytes) to be sent to the driver as a [DirectTaskResult](scheduler/TaskResult.md#DirectTaskResult)

Default: `1048576B` (`1L << 20`)

Used when:

* `TaskRunner` is requested to [run a task](executor/TaskRunner.md#run) (and [decide on the type of a serialized task result](executor/TaskRunner.md#run-serializedResult))

## <span id="spark.task.maxFailures"><span id="TASK_MAX_FAILURES"> spark.task.maxFailures

Number of failures of a single task (of a [TaskSet](scheduler/TaskSet.md)) before giving up on the entire `TaskSet` and then the job

Default: `4`

## <span id="spark.plugins"> spark.plugins

A comma-separated list of class names implementing [org.apache.spark.api.plugin.SparkPlugin](plugins/SparkPlugin.md) to load into a Spark application.

Default: `(empty)`

Since: `3.0.0`

Set when [SparkContext](SparkContext.md) is created

## <span id="spark.plugins.defaultList"> spark.plugins.defaultList

FIXME

## <span id="spark.ui.showConsoleProgress"><span id="UI_SHOW_CONSOLE_PROGRESS"> spark.ui.showConsoleProgress

Controls whether to enable [ConsoleProgressBar](ConsoleProgressBar.md) and show the progress bar in the console

Default: `false`

== [[properties]] Properties

[cols="1m,1",options="header",width="100%"]
|===
| Name
| Description

| spark.blockManager.port
a| [[spark.blockManager.port]][[BLOCK_MANAGER_PORT]] Port to use for block managers to listen on when a more specific setting is not provided (i.e. <<spark.driver.blockManager.port, spark.driver.blockManager.port>> for the driver).

Default: `0`

In Spark on Kubernetes the default port is `7079`

| spark.default.parallelism
a| [[spark.default.parallelism]] Number of partitions to use for rdd:HashPartitioner.md[HashPartitioner]

`spark.default.parallelism` corresponds to scheduler:SchedulerBackend.md#defaultParallelism[default parallelism] of a scheduler backend and is as follows:

* The number of threads for local/spark-LocalSchedulerBackend.md[LocalSchedulerBackend].
* the number of CPU cores in spark-mesos.md#defaultParallelism[Spark on Mesos] and defaults to `8`.
* Maximum of `totalCoreCount` and `2` in scheduler:CoarseGrainedSchedulerBackend.md#defaultParallelism[CoarseGrainedSchedulerBackend].

| spark.driver.blockManager.port
a| [[spark.driver.blockManager.port]][[DRIVER_BLOCK_MANAGER_PORT]] Port the storage:BlockManager.md[block manager] on the driver listens on

Default: <<spark.blockManager.port, spark.blockManager.port>>

| spark.executor.extraClassPath
a| [[spark.executor.extraClassPath]][[EXECUTOR_CLASS_PATH]] *User-defined class path for executors*, i.e. URLs representing user-defined class path entries that are added to an executor's class path. URLs are separated by system-dependent path separator, i.e. `:` on Unix-like systems and `;` on Microsoft Windows.

Default: `(empty)`

Used when:

* Spark Standalone's `StandaloneSchedulerBackend` is requested to spark-standalone:StandaloneSchedulerBackend.md#start[start] (and creates a command for executor:CoarseGrainedExecutorBackend.md[])

* Spark local's `LocalSchedulerBackend` is requested for the spark-local:spark-LocalSchedulerBackend.md#getUserClasspath[user-defined class path for executors]

* Spark on Mesos' `MesosCoarseGrainedSchedulerBackend` is requested to spark-on-mesos:spark-mesos-MesosCoarseGrainedSchedulerBackend.md#createCommand[create a command for CoarseGrainedExecutorBackend]

* Spark on Mesos' `MesosFineGrainedSchedulerBackend` is requested to create a command for `MesosExecutorBackend`

* Spark on Kubernetes' `BasicExecutorFeatureStep` is requested to `configurePod`

* Spark on YARN's `ExecutorRunnable` is requested to spark-on-yarn:spark-yarn-ExecutorRunnable.md#prepareEnvironment[prepareEnvironment] (for `CoarseGrainedExecutorBackend`)

| spark.executor.extraJavaOptions
a| [[spark.executor.extraJavaOptions]] Extra Java options of an executor:Executor.md[]

Used when Spark on YARN's `ExecutorRunnable` is requested to spark-on-yarn:spark-yarn-ExecutorRunnable.md#prepareCommand[prepare the command to launch CoarseGrainedExecutorBackend in a YARN container]

| spark.executor.extraLibraryPath
a| [[spark.executor.extraLibraryPath]] Extra library paths separated by system-dependent path separator, i.e. `:` on Unix/MacOS systems and `;` on Microsoft Windows

Used when Spark on YARN's `ExecutorRunnable` is requested to spark-on-yarn:spark-yarn-ExecutorRunnable.md#prepareCommand[prepare the command to launch CoarseGrainedExecutorBackend in a YARN container]

| spark.executor.uri
a| [[spark.executor.uri]] Equivalent to `SPARK_EXECUTOR_URI`

| spark.executor.logs.rolling.time.interval
a| [[spark.executor.logs.rolling.time.interval]]

| spark.executor.logs.rolling.strategy
a| [[spark.executor.logs.rolling.strategy]]

| spark.executor.logs.rolling.maxRetainedFiles
a| [[spark.executor.logs.rolling.maxRetainedFiles]]

| spark.executor.logs.rolling.maxSize
a| [[spark.executor.logs.rolling.maxSize]]

| spark.executor.heartbeatInterval
a| [[spark.executor.heartbeatInterval]] Interval after which an executor:Executor.md[] reports heartbeat and metrics for active tasks to the driver

Default: `10s`

Refer to executor:Executor.md#heartbeats-and-active-task-metrics[Sending heartbeats and partial metrics for active tasks]

| spark.executor.heartbeat.maxFailures
a| [[spark.executor.heartbeat.maxFailures]] Number of times an executor:Executor.md[] will try to send heartbeats to the driver before it gives up and exits (with exit code `56`).

Default: `60`

NOTE: Introduced in https://issues.apache.org/jira/browse/SPARK-13522[SPARK-13522 Executor should kill itself when it's unable to heartbeat to the driver more than N times].

| spark.executor.instances
a| [[spark.executor.instances]] Number of executor:Executor.md[] in use

Default: `0`

| spark.executor.userClassPathFirst
a| [[spark.executor.userClassPathFirst]] Flag to control whether to load classes in user jars before those in Spark jars

Default: `false`

| spark.executor.port
a| [[spark.executor.port]]

| spark.launcher.port
a| [[spark.launcher.port]]

| spark.launcher.secret
a| [[spark.launcher.secret]]

| spark.locality.wait
a| [[spark.locality.wait]] For locality-aware delay scheduling for `PROCESS_LOCAL`, `NODE_LOCAL`, and `RACK_LOCAL` scheduler:TaskSchedulerImpl.md#TaskLocality[TaskLocalities] when locality-specific setting is not set.

Default: `3s`

| spark.locality.wait.node
a| [[spark.locality.wait.node]] Scheduling delay for `NODE_LOCAL` scheduler:TaskSchedulerImpl.md#TaskLocality[TaskLocality]

Default: The value of <<spark.locality.wait, spark.locality.wait>>

| spark.locality.wait.process
a| [[spark.locality.wait.process]] Scheduling delay for `PROCESS_LOCAL` scheduler:TaskSchedulerImpl.md#TaskLocality[TaskLocality]

Default: The value of <<spark.locality.wait, spark.locality.wait>>

| spark.locality.wait.rack
a| [[spark.locality.wait.rack]] Scheduling delay for `RACK_LOCAL` scheduler:TaskSchedulerImpl.md#TaskLocality[TaskLocality]

Default: The value of <<spark.locality.wait, spark.locality.wait>>

| spark.logging.exceptionPrintInterval
a| [[spark.logging.exceptionPrintInterval]] How frequently to reprint duplicate exceptions in full (in millis).

Default: `10000`

| spark.scheduler.allocation.file
a| [[spark.scheduler.allocation.file]] Path to the configuration file of <<spark-scheduler-FairSchedulableBuilder.md#, FairSchedulableBuilder>>

Default: `fairscheduler.xml` (on a Spark application's class path)

| spark.scheduler.executorTaskBlacklistTime
a| [[spark.scheduler.executorTaskBlacklistTime]] How long to wait before a task can be re-launched on the executor where it once failed. It is to prevent repeated task failures due to executor failures.

Default: `0L`

| spark.scheduler.mode
a| [[spark.scheduler.mode]][[SCHEDULER_MODE_PROPERTY]] *Scheduling Mode* of the scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl], i.e. case-insensitive name of the spark-scheduler-SchedulingMode.md[scheduling mode] that `TaskSchedulerImpl` uses to choose between the <<spark-scheduler-SchedulableBuilder.md#implementations, available SchedulableBuilders>> for task scheduling (of tasks of jobs submitted for execution to the same `SparkContext`)

Default: `FIFO`

Supported values:

* *FAIR* for fair sharing (of cluster resources)
* *FIFO* (default) for queueing jobs one after another

*Task scheduling* is an algorithm that is used to assign cluster resources (CPU cores and memory) to tasks (that are part of jobs with one or more stages). Fair sharing allows for executing tasks of different jobs at the same time (that were all submitted to the same `SparkContext`). In FIFO scheduling mode a single `SparkContext` can submit a single job for execution only (regardless of how many cluster resources the job really use which could lead to a inefficient utilization of cluster resources and a longer execution of the Spark application overall).

Scheduling mode is particularly useful in multi-tenant environments in which a single `SparkContext` could be shared across different users (to make a cluster resource utilization more efficient).

| spark.starvation.timeout
a| [[spark.starvation.timeout]] Threshold above which Spark warns a user that an initial TaskSet may be starved

Default: `15s`

| spark.storage.exceptionOnPinLeak
a| [[spark.storage.exceptionOnPinLeak]]

| spark.unsafe.exceptionOnMemoryLeak
a| [[spark.unsafe.exceptionOnMemoryLeak]]

|===

== [[spark.shuffle.spill.batchSize]] spark.shuffle.spill.batchSize

Size of object batches when reading or writing from serializers.

Default: `10000`

Used by shuffle:ExternalAppendOnlyMap.md[ExternalAppendOnlyMap] and shuffle:ExternalSorter.md[ExternalSorter]

== [[spark.shuffle.mapOutput.dispatcher.numThreads]] spark.shuffle.mapOutput.dispatcher.numThreads

Default: `8`

== [[spark.shuffle.mapOutput.minSizeForBroadcast]] spark.shuffle.mapOutput.minSizeForBroadcast

Size of serialized shuffle map output statuses when scheduler:MapOutputTrackerMaster.md#MessageLoop[MapOutputTrackerMaster] uses to determine whether to use a broadcast variable to send them to executors

Default: `512k`

Must be below [spark.rpc.message.maxSize](#spark.rpc.message.maxSize) (to prevent sending an RPC message that is too large)

== [[spark.shuffle.reduceLocality.enabled]] spark.shuffle.reduceLocality.enabled

Enables locality preferences for reduce tasks

Default: `true`

When enabled (`true`), MapOutputTrackerMaster will scheduler:MapOutputTrackerMaster.md#getPreferredLocationsForShuffle[compute the preferred hosts] on which to run a given map output partition in a given shuffle, i.e. the nodes that the most outputs for that partition are on.

== [[spark.shuffle.sort.initialBufferSize]] spark.shuffle.sort.initialBufferSize

Initial buffer size for sorting

Default: shuffle:UnsafeShuffleWriter.md#DEFAULT_INITIAL_SORT_BUFFER_SIZE[4096]

Used exclusively when `UnsafeShuffleWriter` is requested to shuffle:UnsafeShuffleWriter.md#open[open] (and creates a shuffle:ShuffleExternalSorter.md[ShuffleExternalSorter])

== [[spark.shuffle.unsafe.file.output.buffer]] spark.shuffle.unsafe.file.output.buffer

The file system for this buffer size after each partition is written in unsafe shuffle writer. In KiB unless otherwise specified.

Default: `32k`

Must be greater than `0` and less than or equal to `2097151` (`(Integer.MAX_VALUE - 15) / 1024`)

== [[spark.scheduler.maxRegisteredResourcesWaitingTime]] spark.scheduler.maxRegisteredResourcesWaitingTime

Time to wait for sufficient resources available

Default: `30s`

== [[spark.shuffle.unsafe.fastMergeEnabled]] spark.shuffle.unsafe.fastMergeEnabled

Enables fast merge strategy for UnsafeShuffleWriter to shuffle:UnsafeShuffleWriter.md#mergeSpills[merge spill files].

Default: `true`

== [[spark.shuffle.spill.compress]] spark.shuffle.spill.compress

Controls whether to compress shuffle output temporarily spilled to disk.

Default: `true`

== [[spark.block.failures.beforeLocationRefresh]] spark.block.failures.beforeLocationRefresh

Default: `5`

== [[spark.closure.serializer]] spark.closure.serializer

serializer:Serializer.md[Serializer]

Default: `org.apache.spark.serializer.JavaSerializer`

== [[spark.io.compression.codec]] spark.io.compression.codec

The default io:CompressionCodec.md[CompressionCodec]

Default: `lz4`

== [[spark.io.compression.lz4.blockSize]] spark.io.compression.lz4.blockSize

The block size of the io:CompressionCodec.md#LZ4CompressionCodec[LZ4CompressionCodec]

Default: `32k`

== [[spark.io.compression.snappy.blockSize]] spark.io.compression.snappy.blockSize

The block size of the io:CompressionCodec.md#SnappyCompressionCodec[SnappyCompressionCodec]

Default: `32k`

== [[spark.io.compression.zstd.bufferSize]] spark.io.compression.zstd.bufferSize

The buffer size of the BufferedOutputStream of the io:CompressionCodec.md#ZStdCompressionCodec[ZStdCompressionCodec]

Default: `32k`

The buffer is used to avoid the overhead of excessive JNI calls while compressing or uncompressing small amount of data

== [[spark.io.compression.zstd.level]] spark.io.compression.zstd.level

The compression level of the io:CompressionCodec.md#ZStdCompressionCodec[ZStdCompressionCodec]

Default: `1`

The default level is the fastest of all with reasonably high compression ratio

== [[spark.buffer.size]] spark.buffer.size

Default: `65536`

== [[spark.cleaner.referenceTracking.cleanCheckpoints]] spark.cleaner.referenceTracking.cleanCheckpoints

Enables cleaning checkpoint files when a checkpointed reference is out of scope

Default: `false`


== [[spark.cleaner.periodicGC.interval]] spark.cleaner.periodicGC.interval

Controls how often to trigger a garbage collection

Default: `30min`

== [[spark.cleaner.referenceTracking.blocking]] spark.cleaner.referenceTracking.blocking

Controls whether the cleaning thread should block on cleanup tasks (other than shuffle, which is controlled by <<spark.cleaner.referenceTracking.blocking.shuffle, spark.cleaner.referenceTracking.blocking.shuffle>>)

Default: `true`

== [[spark.cleaner.referenceTracking.blocking.shuffle]] spark.cleaner.referenceTracking.blocking.shuffle

Controls whether the cleaning thread should block on shuffle cleanup tasks.

Default: `false`

== [[spark.app.name]] spark.app.name

Application Name

Default: (undefined)

== [[spark.rpc.numRetries]] spark.rpc.numRetries

Number of attempts to send a message to and receive a response from a remote endpoint.

Default: `3`

== [[spark.rpc.retry.wait]] spark.rpc.retry.wait

Time to wait between retries.

Default: `3s`

== [[spark.rpc.askTimeout]] spark.rpc.askTimeout

Timeout for RPC ask calls

Default: `120s`
