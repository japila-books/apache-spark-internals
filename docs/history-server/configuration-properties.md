# Configuration Properties

The following contains the configuration properties of [EventLoggingListener](EventLoggingListener.md) and [HistoryServer](HistoryServer.md).

## <span id="spark.eventLog.dir"> spark.eventLog.dir

Directory where Spark events are logged to (e.g. `hdfs://namenode:8021/directory`)

Default: `/tmp/spark-events`

The directory must exist before [SparkContext](../SparkContext.md) is created.

## <span id="spark.eventLog.buffer.kb"> spark.eventLog.buffer.kb

Size of the buffer to use when writing to output streams.

Default: `100`

## <span id="spark.eventLog.compress"> spark.eventLog.compress

Whether to enable (`true`) or disable (`false`) event compression (using a [CompressionCodec](../CompressionCodec.md))

Default: `false`

## <span id="spark.eventLog.enabled"> spark.eventLog.enabled

Whether to enable (`true`) or disable (`false`) persisting Spark events.

Default: `false`

## <span id="spark.eventLog.logBlockUpdates.enabled"><span id="EVENT_LOG_BLOCK_UPDATES"> spark.eventLog.logBlockUpdates.enabled

Whether [EventLoggingListener](EventLoggingListener.md) should log RDD block updates (`true`) or not (`false`)

Default: `false`

## <span id="spark.eventLog.overwrite"> spark.eventLog.overwrite

Whether to enable (`true`) or disable (`false`) deleting (or at least overwriting) an existing [.inprogress](EventLoggingListener.md#inprogress) event log files

Default: `false`

## <span id="spark.history.fs.logDirectory"> spark.history.fs.logDirectory

The directory for event log files. The directory has to exist before starting History Server.

Default: `file:/tmp/spark-events`

## <span id="spark.history.kerberos.enabled"> spark.history.kerberos.enabled

Whether to enable (`true`) or disable (`false`) security when working with HDFS with security enabled (Kerberos).

Default: `false`

## <span id="spark.history.kerberos.keytab"> spark.history.kerberos.keytab

Keytab to use for login to Kerberos. Required when `spark.history.kerberos.enabled` is enabled.

Default: (empty)

## <span id="spark.history.kerberos.principal"> spark.history.kerberos.principal

Kerberos principal. Required when `spark.history.kerberos.enabled` is enabled.

Default: (empty)

## <span id="spark.history.provider"><span id="PROVIDER"> spark.history.provider

Fully-qualified class name of an [ApplicationHistoryProvider](ApplicationHistoryProvider.md) for [HistoryServer](HistoryServer.md#main).

Default: [org.apache.spark.deploy.history.FsHistoryProvider](FsHistoryProvider.md)

## <span id="spark.history.store.path"><span id="LOCAL_STORE_DIR"> spark.history.store.path

Local directory where to cache application history information (by )

Default: (undefined) (i.e. all history information will be kept in memory)

## <span id="spark.history.retainedApplications"> spark.history.retainedApplications

How many Spark applications [HistoryServer](HistoryServer.md#retainedApplications) should retain

Default: `50`

## <span id="spark.history.ui.maxApplications"><span id="HISTORY_UI_MAX_APPS"> spark.history.ui.maxApplications

How many Spark applications [HistoryServer](HistoryServer.md#maxApplications) should show in the UI

Default: (unbounded)

## <span id="spark.history.ui.port"><span id="HISTORY_SERVER_UI_PORT"> spark.history.ui.port

The port of History Server's web UI.

Default: `18080`
