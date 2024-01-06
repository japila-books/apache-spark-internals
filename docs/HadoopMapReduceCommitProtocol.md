# HadoopMapReduceCommitProtocol

`HadoopMapReduceCommitProtocol` is a [FileCommitProtocol](FileCommitProtocol.md).

`HadoopMapReduceCommitProtocol` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)) (to be sent out in tasks over the wire to executors).

## Creating Instance

`HadoopMapReduceCommitProtocol` takes the following to be created:

* <span id="jobId"> Job ID
* <span id="path"> Path
* <span id="dynamicPartitionOverwrite"> `dynamicPartitionOverwrite` flag (default: `false`)

`HadoopMapReduceCommitProtocol` is created when:

* `HadoopWriteConfigUtil` is requested to [create a committer](HadoopWriteConfigUtil.md#createCommitter)
* `HadoopMapReduceWriteConfigUtil` is requested to [create a committer](HadoopMapReduceWriteConfigUtil.md#createCommitter)
* `HadoopMapRedWriteConfigUtil` is requested to [create a committer](HadoopMapRedWriteConfigUtil.md#createCommitter)

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.io.HadoopMapReduceCommitProtocol` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.HadoopMapReduceCommitProtocol.name = org.apache.spark.internal.io.HadoopMapReduceCommitProtocol
logger.HadoopMapReduceCommitProtocol.level = all
```

Refer to [Logging](spark-logging.md).
