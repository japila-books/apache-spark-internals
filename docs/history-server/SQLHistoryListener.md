== SQLHistoryListener

`SQLHistoryListener` is a custom spark-sql-SQLListener.md[SQLListener] for index.md[History Server]. It attaches spark-sql-webui.md#creating-instance[SQL tab] to History Server's web UI only when the first spark-sql-SQLListener.md#SparkListenerSQLExecutionStart[SparkListenerSQLExecutionStart] arrives and shuts <<onExecutorMetricsUpdate, onExecutorMetricsUpdate>> off. It also handles <<onTaskEnd, ends of tasks in a slightly different way>>.

NOTE: Support for SQL UI in History Server was added in SPARK-11206 Support SQL UI on the history server.

CAUTION: FIXME Add the link to the JIRA.

=== [[onOtherEvent]] onOtherEvent

[source, scala]
----
onOtherEvent(event: SparkListenerEvent): Unit
----

When `SparkListenerSQLExecutionStart` event comes, `onOtherEvent` attaches spark-sql-webui.md#creating-instance[SQL tab] to web UI and passes the call to the parent spark-sql-SQLListener.md[SQLListener].

=== [[onTaskEnd]] onTaskEnd

CAUTION: FIXME

=== [[creating-instance]] Creating SQLHistoryListener Instance

`SQLHistoryListener` is created using a (`private[sql]`) `SQLHistoryListenerFactory` class (which is `SparkHistoryListenerFactory`).

The `SQLHistoryListenerFactory` class is registered when spark-webui-SparkUI.md#createHistoryUI[`SparkUI` creates a web UI for History Server] as a Java service in `META-INF/services/org.apache.spark.scheduler.SparkHistoryListenerFactory`:

```
org.apache.spark.sql.execution.ui.SQLHistoryListenerFactory
```

NOTE: Loading the service uses Java's https://docs.oracle.com/javase/8/docs/api/java/util/ServiceLoader.html#load-java.lang.Class-java.lang.ClassLoader-[ServiceLoader.load] method.

=== [[onExecutorMetricsUpdate]] onExecutorMetricsUpdate

`onExecutorMetricsUpdate` does nothing.
