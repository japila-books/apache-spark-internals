# Spark Configuration Properties

## <span id="spark.app.id"> spark.app.id

Unique identifier of a Spark application that Spark uses to uniquely identify [metric sources](metrics/MetricsSystem.md#buildRegistryName).

Default: [TaskScheduler.applicationId()](scheduler/TaskScheduler.md#applicationId)

Set when [SparkContext](SparkContext.md) is created

## <span id="spark.extraListeners"> spark.extraListeners

A comma-separated list of fully-qualified class names of [SparkListener](SparkListener.md)s (to be registered when [SparkContext](SparkContext.md) is created)

Default: (empty)

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

| spark.diskStore.subDirectories
a| [[spark.diskStore.subDirectories]]

Default: `64`

| spark.driver.blockManager.port
a| [[spark.driver.blockManager.port]][[DRIVER_BLOCK_MANAGER_PORT]] Port the storage:BlockManager.md[block manager] on the driver listens on

Default: <<spark.blockManager.port, spark.blockManager.port>>

| spark.driver.maxResultSize
a| [[maxResultSize]][[spark.driver.maxResultSize]][[MAX_RESULT_SIZE]] The maximum size of all results of the tasks in a `TaskSet`

Default: `1g`

Used when:

* `Executor` is executor:Executor.md#maxResultSize[created] (and later for a executor:TaskRunner.md[])

* `TaskSetManager` is scheduler:TaskSetManager.md#maxResultSize[created] (and later requested to scheduler:TaskSetManager.md#canFetchMoreResults[check available memory for task results])

| spark.executor.extraClassPath
a| [[spark.executor.extraClassPath]][[EXECUTOR_CLASS_PATH]] *User-defined class path for executors*, i.e. URLs representing user-defined class path entries that are added to an executor's class path. URLs are separated by system-dependent path separator, i.e. `:` on Unix-like systems and `;` on Microsoft Windows.

Default: `(empty)`

Used when:

* Spark Standalone's `StandaloneSchedulerBackend` is requested to spark-standalone:spark-standalone-StandaloneSchedulerBackend.md#start[start] (and creates a command for executor:CoarseGrainedExecutorBackend.md[])

* Spark local's `LocalSchedulerBackend` is requested for the spark-local:spark-LocalSchedulerBackend.md#getUserClasspath[user-defined class path for executors]

* Spark on Mesos' `MesosCoarseGrainedSchedulerBackend` is requested to spark-on-mesos:spark-mesos-MesosCoarseGrainedSchedulerBackend.md#createCommand[create a command for CoarseGrainedExecutorBackend]

* Spark on Mesos' `MesosFineGrainedSchedulerBackend` is requested to create a command for `MesosExecutorBackend`

* Spark on Kubernetes' `BasicExecutorFeatureStep` is requested to `configurePod`

* Spark on YARN's `ExecutorRunnable` is requested to spark-on-yarn:spark-yarn-ExecutorRunnable.md#prepareEnvironment[prepareEnvironment] (for `CoarseGrainedExecutorBackend`)

| spark.executor.cores
a| [[spark.executor.cores]] Number of cores of an executor:Executor.md[]

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

| spark.executor.id
a| [[spark.executor.id]]

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

| spark.task.maxDirectResultSize
a| [[spark.task.maxDirectResultSize]]

Default: `1048576B`

| spark.executor.userClassPathFirst
a| [[spark.executor.userClassPathFirst]] Flag to control whether to load classes in user jars before those in Spark jars

Default: `false`

| spark.executor.memory
a| [[spark.executor.memory]] Amount of memory to use for an executor:Executor.md[]

Default: `1g`

Equivalent to ROOT:SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY] environment variable.

Refer to executor:Executor.md#memory[Executor Memory -- spark.executor.memory or SPARK_EXECUTOR_MEMORY settings]

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

| spark.master
a| [[spark.master]] *Master URL* to connect a Spark application to

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

TIP: Use web UI to know the current scheduling mode (e.g. <<spark-webui-environment.md#, Environment>> tab as part of *Spark Properties* and <<spark-webui-jobs.md#, Jobs>> tab as *Scheduling Mode*).

| spark.starvation.timeout
a| [[spark.starvation.timeout]] Threshold above which Spark warns a user that an initial TaskSet may be starved

Default: `15s`

| spark.storage.exceptionOnPinLeak
a| [[spark.storage.exceptionOnPinLeak]]

| spark.task.cpus
a| [[spark.task.cpus]][[CPUS_PER_TASK]] The number of CPU cores used to schedule (_allocate for_) a task

Default: `1`

Used when:

* `ExecutorAllocationManager` is <<spark-ExecutorAllocationManager.md#tasksPerExecutorForFullParallelism, created>>

* `TaskSchedulerImpl` is scheduler:TaskSchedulerImpl.md#CPUS_PER_TASK[created]

* AppStatusListener is requested to core:AppStatusListener.md#onEnvironmentUpdate[handle an SparkListenerEnvironmentUpdate event]

* `LocalityPreferredContainerPlacementStrategy` is requested to `numExecutorsPending`

| spark.task.maxFailures
a| [[spark.task.maxFailures]] The number of individual task failures before giving up on the entire scheduler:TaskSet.md[TaskSet] and the job afterwards

Default:

* `1` in spark-local:spark-local.md[local]
* `maxFailures` in spark-local:spark-local.md#masterURL[local-with-retries]
* `4` in spark-cluster.md[cluster mode]

| spark.unsafe.exceptionOnMemoryLeak
a| [[spark.unsafe.exceptionOnMemoryLeak]]

|===

== [[spark.memory.offHeap.size]][[MEMORY_OFFHEAP_SIZE]] spark.memory.offHeap.size

Maximum memory (in bytes) for off-heap memory allocation.

Default: `0`

This setting has no impact on heap memory usage, so if your executors' total memory consumption must fit within some hard limit then be sure to shrink your JVM heap size accordingly.

Must be set to a positive value when <<spark.memory.offHeap.enabled, spark.memory.offHeap.enabled>> is enabled (`true`).

Must not be negative

== [[spark.memory.storageFraction]] spark.memory.storageFraction

Fraction of the memory to use for off-heap storage region.

Default: `0.5`

== [[spark.memory.fraction]] spark.memory.fraction

`spark.memory.fraction` is the fraction of JVM heap space used for execution and storage.

Default: `0.6`

== [[spark.memory.useLegacyMode]] spark.memory.useLegacyMode

Controls the type of memory:MemoryManager.md[MemoryManager] to use. When enabled (i.e. `true`) it is the legacy memory:StaticMemoryManager.md[StaticMemoryManager] while memory:UnifiedMemoryManager.md[UnifiedMemoryManager] otherwise (i.e. `false`).

Default: `false`

== [[spark.memory.offHeap.enabled]] spark.memory.offHeap.enabled

`spark.memory.offHeap.enabled` controls whether Spark will attempt to use off-heap memory for certain operations (`true`) or not (`false`).

Default: `false`

Tracks whether Tungsten memory will be allocated on the JVM heap or off-heap (using `sun.misc.Unsafe`).

If enabled, <<spark.memory.offHeap.size, spark.memory.offHeap.size>> has to be memory:MemoryManager.md#tungstenMemoryMode[greater than 0].

Used when MemoryManager is requested for memory:MemoryManager.md#tungstenMemoryMode[tungstenMemoryMode].

== [[spark.shuffle.file.buffer]] spark.shuffle.file.buffer

Size of the in-memory buffer for each shuffle file output stream, in KiB unless otherwise specified. These buffers reduce the number of disk seeks and system calls made in creating intermediate shuffle files.

Default: `32k`

Must be greater than `0` and less than or equal to `2097151` (`(Integer.MAX_VALUE - 15) / 1024`)

== [[spark.shuffle.spill.batchSize]] spark.shuffle.spill.batchSize

Size of object batches when reading or writing from serializers.

Default: `10000`

Used by shuffle:ExternalAppendOnlyMap.md[ExternalAppendOnlyMap] and shuffle:ExternalSorter.md[ExternalSorter]

== [[spark.shuffle.spill.initialMemoryThreshold]] spark.shuffle.spill.initialMemoryThreshold

Initial threshold for the size of an in-memory collection

Default: `5 * 1024 * 1024`

Used by shuffle:Spillable.md[Spillable]

== [[spark.shuffle.spill.numElementsForceSpillThreshold]][[SHUFFLE_SPILL_NUM_ELEMENTS_FORCE_SPILL_THRESHOLD]] spark.shuffle.spill.numElementsForceSpillThreshold

*(internal)* The maximum number of elements in memory before forcing the shuffle sorter to spill. Claimed to be used for testing only

Default: `Integer.MAX_VALUE`

The default value is to never force the sorter to spill, until we reach some limitations, like the max page size limitation for the pointer array in the sorter.

Used when:

* ShuffleExternalSorter is created

* Spillable is requested to shuffle:Spillable.md#maybeSpill[maybeSpill]

== [[spark.shuffle.manager]] spark.shuffle.manager

Specifies the fully-qualified class name or the <<spark.shuffle.manager-aliases, alias>> of the shuffle:ShuffleManager.md[ShuffleManager] in a Spark application

Default: `sort`

[[spark.shuffle.manager-aliases]]
The supported aliases:

* [[spark.shuffle.manager-sort]] `sort`

* [[spark.shuffle.manager-tungsten-sort]] `tungsten-sort`

Used when `SparkEnv` object is requested to core:SparkEnv.md#create[create a "base" SparkEnv for a driver or an executor]

== [[spark.shuffle.mapOutput.dispatcher.numThreads]] spark.shuffle.mapOutput.dispatcher.numThreads

Default: `8`

== [[spark.shuffle.mapOutput.minSizeForBroadcast]] spark.shuffle.mapOutput.minSizeForBroadcast

Size of serialized shuffle map output statuses when scheduler:MapOutputTrackerMaster.md#MessageLoop[MapOutputTrackerMaster] uses to determine whether to use a broadcast variable to send them to executors

Default: `512k`

Must be below <<spark.rpc.message.maxSize, spark.rpc.message.maxSize>> (to prevent sending an RPC message that is too large)

== [[spark.rpc.message.maxSize]] spark.rpc.message.maxSize

Maximum allowed message size for RPC communication (in `MB` unless specified)

Default: `128`

Generally only applies to map output size (serialized) information sent between executors and the driver.

Increase this if you are running jobs with many thousands of map and reduce tasks and see messages about the RPC message size.

== [[spark.shuffle.minNumPartitionsToHighlyCompress]] spark.shuffle.minNumPartitionsToHighlyCompress

*(internal)* Minimum number of partitions (threshold) when `MapStatus` object creates a scheduler:MapStatus.md#HighlyCompressedMapStatus[HighlyCompressedMapStatus] (over scheduler:MapStatus.md#CompressedMapStatus[CompressedMapStatus]) when requested for scheduler:MapStatus.md#apply[one] (for shuffle:ShuffleWriter.md[ShuffleWriters]).

Default: `2000`

Must be a positive integer (above `0`)

== [[spark.shuffle.reduceLocality.enabled]] spark.shuffle.reduceLocality.enabled

Enables locality preferences for reduce tasks

Default: `true`

When enabled (`true`), MapOutputTrackerMaster will scheduler:MapOutputTrackerMaster.md#getPreferredLocationsForShuffle[compute the preferred hosts] on which to run a given map output partition in a given shuffle, i.e. the nodes that the most outputs for that partition are on.

== [[spark.shuffle.sort.bypassMergeThreshold]] spark.shuffle.sort.bypassMergeThreshold

Maximum number of reduce partitions below which shuffle:SortShuffleManager.md[SortShuffleManager] avoids merge-sorting data for no map-side aggregation

Default: `200`

== [[spark.shuffle.sort.initialBufferSize]] spark.shuffle.sort.initialBufferSize

Initial buffer size for sorting

Default: shuffle:UnsafeShuffleWriter.md#DEFAULT_INITIAL_SORT_BUFFER_SIZE[4096]

Used exclusively when `UnsafeShuffleWriter` is requested to shuffle:UnsafeShuffleWriter.md#open[open] (and creates a shuffle:ShuffleExternalSorter.md[ShuffleExternalSorter])

== [[spark.shuffle.sync]] spark.shuffle.sync

Controls whether DiskBlockObjectWriter should force outstanding writes to disk while storage:DiskBlockObjectWriter.md#commitAndGet[committing a single atomic block], i.e. all operating system buffers should synchronize with the disk to ensure that all changes to a file are in fact recorded in the storage.

Default: `false`

Used when BlockManager is requested for a storage:BlockManager.md#getDiskWriter[DiskBlockObjectWriter]

== [[spark.shuffle.unsafe.file.output.buffer]] spark.shuffle.unsafe.file.output.buffer

The file system for this buffer size after each partition is written in unsafe shuffle writer. In KiB unless otherwise specified.

Default: `32k`

Must be greater than `0` and less than or equal to `2097151` (`(Integer.MAX_VALUE - 15) / 1024`)

== [[spark.scheduler.revive.interval]] spark.scheduler.revive.interval

Time (in ms) between resource offers revives

Default: `1s`

== [[spark.scheduler.minRegisteredResourcesRatio]] spark.scheduler.minRegisteredResourcesRatio

Minimum ratio of (registered resources / total expected resources) before submitting tasks

Default: `0`

== [[spark.scheduler.maxRegisteredResourcesWaitingTime]] spark.scheduler.maxRegisteredResourcesWaitingTime

Time to wait for sufficient resources available

Default: `30s`

== [[spark.file.transferTo]] spark.file.transferTo

When enabled (`true`), copying data between two Java FileInputStreams uses Java FileChannels (Java NIO) to improve copy performance.

Default: `true`

== [[spark.shuffle.service.enabled]][[SHUFFLE_SERVICE_ENABLED]] spark.shuffle.service.enabled

Controls whether to use the deploy:ExternalShuffleService.md[External Shuffle Service]

Default: `false`

When enabled (`true`), the driver registers itself with the shuffle service.

== [[spark.shuffle.service.port]] spark.shuffle.service.port

Default: `7337`

== [[spark.shuffle.compress]] spark.shuffle.compress

Controls whether to compress shuffle output when stored

Default: `true`

== [[spark.shuffle.unsafe.fastMergeEnabled]] spark.shuffle.unsafe.fastMergeEnabled

Enables fast merge strategy for UnsafeShuffleWriter to shuffle:UnsafeShuffleWriter.md#mergeSpills[merge spill files].

Default: `true`

== [[spark.rdd.compress]] spark.rdd.compress

Controls whether to compress RDD partitions when stored serialized.

Default: `false`

== [[spark.shuffle.spill.compress]] spark.shuffle.spill.compress

Controls whether to compress shuffle output temporarily spilled to disk.

Default: `true`

== [[spark.block.failures.beforeLocationRefresh]] spark.block.failures.beforeLocationRefresh

Default: `5`

== [[spark.io.encryption.enabled]] spark.io.encryption.enabled

Controls whether to use IO encryption

Default: `false`

== [[spark.closure.serializer]] spark.closure.serializer

serializer:Serializer.md[Serializer]

Default: `org.apache.spark.serializer.JavaSerializer`

== [[spark.serializer]] spark.serializer

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

== [[spark.cleaner.referenceTracking]] spark.cleaner.referenceTracking

Controls whether to enable ContextCleaner

Default: `true`

== [[spark.cleaner.referenceTracking.blocking]] spark.cleaner.referenceTracking.blocking

Controls whether the cleaning thread should block on cleanup tasks (other than shuffle, which is controlled by <<spark.cleaner.referenceTracking.blocking.shuffle, spark.cleaner.referenceTracking.blocking.shuffle>>)

Default: `true`

== [[spark.cleaner.referenceTracking.blocking.shuffle]] spark.cleaner.referenceTracking.blocking.shuffle

Controls whether the cleaning thread should block on shuffle cleanup tasks.

Default: `false`

== [[spark.broadcast.blockSize]] spark.broadcast.blockSize

The size of a block (in kB unless the unit is specified)

Default: `4m`

Used when core:TorrentBroadcast.md#writeBlocks[`TorrentBroadcast` stores brodcast blocks to `BlockManager`]

== [[spark.broadcast.compress]] spark.broadcast.compress

Controls broadcast compression

Default: `true`

Used when core:TorrentBroadcast.md#creating-instance[`TorrentBroadcast` is created] and later when core:TorrentBroadcast.md#writeBlocks[it stores broadcast blocks to `BlockManager`]. Also in serializer:SerializerManager.md#settings[SerializerManager].

== [[spark.app.name]] spark.app.name

Application Name

Default: (undefined)

== [[spark.rpc.lookupTimeout]] spark.rpc.lookupTimeout

Timeout to use for the rpc:RpcEnv.md#defaultLookupTimeout[Default Endpoint Lookup Timeout]

Default: `120s`

== [[spark.rpc.numRetries]] spark.rpc.numRetries

Number of attempts to send a message to and receive a response from a remote endpoint.

Default: `3`

== [[spark.rpc.retry.wait]] spark.rpc.retry.wait

Time to wait between retries.

Default: `3s`

== [[spark.rpc.askTimeout]] spark.rpc.askTimeout

Timeout for RPC ask calls

Default: `120s`

== [[spark.network.timeout]] spark.network.timeout

Network timeout to use for RPC remote endpoint lookup. Fallback for <<spark.rpc.askTimeout, spark.rpc.askTimeout>>.

Default: `120s`

== [[spark.speculation]] spark.speculation

Enables (`true`) or disables (`false`) ROOT:speculative-execution-of-tasks.md[]

Default: `false`

== [[spark.speculation.interval]] spark.speculation.interval

The time interval to use before checking for speculative tasks in ROOT:speculative-execution-of-tasks.md[].

Default: `100ms`

== [[spark.speculation.multiplier]] spark.speculation.multiplier

Default: `1.5`

== [[spark.speculation.quantile]] spark.speculation.quantile

The percentage of tasks that has not finished yet at which to start speculation in ROOT:speculative-execution-of-tasks.md[].

Default: `0.75`

== [[spark.storage.unrollMemoryThreshold]] spark.storage.unrollMemoryThreshold

Initial per-task memory size needed to store a block in memory.

Default: `1024 * 1024`

Must be at most the storage:MemoryStore.md#maxMemory[total amount of memory available for storage]

Used when MemoryStore is requested to storage:MemoryStore.md#putIterator[putIterator] and storage:MemoryStore.md#putIteratorAsBytes[putIteratorAsBytes]
