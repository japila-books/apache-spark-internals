# Configuration Properties

The following contains the configuration properties of [EventLoggingListener](EventLoggingListener.md) and [HistoryServer](HistoryServer.md).

## <span id="spark.eventLog"> spark.eventLog

### <span id="spark.eventLog.buffer.kb"><span id="EVENT_LOG_OUTPUT_BUFFER_SIZE"> buffer.kb

**spark.eventLog.buffer.kb**

Size of the buffer to use when writing to output streams

Default: `100k`

### <span id="spark.eventLog.compress"><span id="EVENT_LOG_COMPRESS"> compress

**spark.eventLog.compress**

Enables event compression (using a `CompressionCodec`)

Default: `false`

### <span id="spark.eventLog.compression.codec"><span id="EVENT_LOG_COMPRESSION_CODEC"> compression.codec

**spark.eventLog.compression.codec**

The codec used to compress event log (with [spark.eventLog.compress](#spark.eventLog.compress) enabled).
By default, Spark provides four codecs: lz4, lzf, snappy, and zstd.
You can also use fully qualified class names to specify the codec.

Default: `zstd`

### <span id="spark.eventLog.dir"><span id="EVENT_LOG_DIR"> dir

**spark.eventLog.dir**

Directory where Spark events are logged to (e.g. `hdfs://namenode:8021/directory`)

Default: `/tmp/spark-events`

The directory must exist before [SparkContext](../SparkContext.md) can be created

### <span id="spark.eventLog.enabled"><span id="EVENT_LOG_ENABLED"> enabled

**spark.eventLog.enabled**

Enables persisting Spark events

Default: `false`

### <span id="spark.eventLog.erasureCoding.enabled"><span id="EVENT_LOG_ALLOW_EC"> erasureCoding.enabled

**spark.eventLog.erasureCoding.enabled**

Default: `false`

### <span id="spark.eventLog.gcMetrics.youngGenerationGarbageCollectors"><span id="EVENT_LOG_GC_METRICS_YOUNG_GENERATION_GARBAGE_COLLECTORS"> gcMetrics.youngGenerationGarbageCollectors

**spark.eventLog.gcMetrics.youngGenerationGarbageCollectors**

Names of supported young generation garbage collectors.
A name usually is the output of `GarbageCollectorMXBean.getName`.

Default: `Copy`, `PS Scavenge`, `ParNew`, `G1 Young Generation` (the built-in young generation garbage collectors)

### <span id="spark.eventLog.gcMetrics.oldGenerationGarbageCollectors"><span id="EVENT_LOG_GC_METRICS_OLD_GENERATION_GARBAGE_COLLECTORS"> gcMetrics.oldGenerationGarbageCollectors

**spark.eventLog.gcMetrics.oldGenerationGarbageCollectors**

Names of supported old generation garbage collectors.
A name usually is the output of `GarbageCollectorMXBean.getName`.

Default: `MarkSweepCompact`, `PS MarkSweep`, `ConcurrentMarkSweep`, `G1 Old Generation` (the built-in old generation garbage collectors)

### <span id="spark.eventLog.logBlockUpdates.enabled"><span id="EVENT_LOG_BLOCK_UPDATES"> logBlockUpdates.enabled

**spark.eventLog.logBlockUpdates.enabled**

Enables log RDD block updates using [EventLoggingListener](EventLoggingListener.md)

Default: `false`

### <span id="spark.eventLog.logStageExecutorMetrics"><span id="EVENT_LOG_STAGE_EXECUTOR_METRICS"> logStageExecutorMetrics

**spark.eventLog.logStageExecutorMetrics**

Enables logging of per-stage peaks of executor metrics (for each executor) to the event log

Default: `false`

### <span id="spark.eventLog.longForm.enabled"><span id="EVENT_LOG_CALLSITE_LONG_FORM"> longForm.enabled

**spark.eventLog.longForm.enabled**

Default: `false`

### <span id="spark.eventLog.overwrite"><span id="EVENT_LOG_OVERWRITE"> overwrite

**spark.eventLog.overwrite**

Enables deleting (or at least overwriting) an existing [.inprogress](EventLoggingListener.md#inprogress) event log files

Default: `false`

### <span id="spark.eventLog.rolling.enabled"><span id="EVENT_LOG_ENABLE_ROLLING"> rolling.enabled

**spark.eventLog.rolling.enabled**

Enables rolling over event log files.
When enabled, cuts down each event log file to [spark.eventLog.rolling.maxFileSize](#spark.eventLog.rolling.maxFileSize)

Default: `false`

### <span id="spark.eventLog.rolling.maxFileSize"><span id="EVENT_LOG_ROLLING_MAX_FILE_SIZE"> rolling.maxFileSize

**spark.eventLog.rolling.maxFileSize**

Max size of event log file to be rolled over (with [spark.eventLog.rolling.enabled](#spark.eventLog.rolling.enabled) enabled)

Default: `128m`

Must be at least 10 MiB

## <span id="spark.history"> spark.history

### <span id="spark.history.fs.logDirectory"> fs.logDirectory

**spark.history.fs.logDirectory**

The directory for event log files. The directory has to exist before starting History Server.

Default: `file:/tmp/spark-events`

### <span id="spark.history.kerberos.enabled"> kerberos.enabled

**spark.history.kerberos.enabled**

Whether to enable (`true`) or disable (`false`) security when working with HDFS with security enabled (Kerberos).

Default: `false`

### <span id="spark.history.kerberos.keytab"> kerberos.keytab

**spark.history.kerberos.keytab**

Keytab to use for login to Kerberos. Required when `spark.history.kerberos.enabled` is enabled.

Default: (empty)

### <span id="spark.history.kerberos.principal"> kerberos.principal

**spark.history.kerberos.principal**

Kerberos principal. Required when `spark.history.kerberos.enabled` is enabled.

Default: (empty)

### <span id="spark.history.provider"><span id="PROVIDER"> provider

**spark.history.provider**

Fully-qualified class name of an [ApplicationHistoryProvider](ApplicationHistoryProvider.md) for [HistoryServer](HistoryServer.md#main).

Default: [org.apache.spark.deploy.history.FsHistoryProvider](FsHistoryProvider.md)

### <span id="spark.history.retainedApplications"> retainedApplications

**spark.history.retainedApplications**

How many Spark applications [HistoryServer](HistoryServer.md#retainedApplications) should retain

Default: `50`

### <span id="spark.history.store.path"><span id="LOCAL_STORE_DIR"> store.path

**spark.history.store.path**

Local directory where to cache application history information (by )

Default: (undefined) (i.e. all history information will be kept in memory)

### <span id="spark.history.ui.maxApplications"><span id="HISTORY_UI_MAX_APPS"> ui.maxApplications

**spark.history.ui.maxApplications**

How many Spark applications [HistoryServer](HistoryServer.md#maxApplications) should show in the UI

Default: (unbounded)

### <span id="spark.history.ui.port"><span id="HISTORY_SERVER_UI_PORT"> ui.port

**spark.history.ui.port**

The port of History Server's web UI.

Default: `18080`
