# OutputCommitCoordinator

From the scaladoc (it's a `private[spark]` class so no way to find it [outside the code]({{ spark.github }}/core/src/main/scala/org/apache/spark/scheduler/OutputCommitCoordinator.scala#L37-L45)):

> Authority that decides whether tasks can commit output to HDFS. Uses a "first committer wins" policy.
>
> OutputCommitCoordinator is instantiated in both the drivers and executors. On executors, it is configured with a reference to the driver's OutputCommitCoordinatorEndpoint, so requests to commit output will be forwarded to the driver's OutputCommitCoordinator.
>
> This class was introduced in [SPARK-4879](https://issues.apache.org/jira/browse/SPARK-4879); see that JIRA issue (and the associated pull requests) for an extensive design discussion.

## Creating Instance

`OutputCommitCoordinator` takes the following to be created:

* <span id="conf"> [SparkConf](SparkConf.md)
* <span id="isDriver"> `isDriver` flag

`OutputCommitCoordinator` is created when:

* `SparkEnv` utility is used to [create a SparkEnv on the driver](SparkEnv.md#create)

## <span id="coordinatorRef"> OutputCommitCoordinator RPC Endpoint

```scala
coordinatorRef: Option[RpcEndpointRef]
```

`OutputCommitCoordinator` is registered as **OutputCommitCoordinator** (with `OutputCommitCoordinatorEndpoint` RPC Endpoint) in the [RPC Environment](rpc/index.md) on the driver (when `SparkEnv` utility is used to [create "base" SparkEnv](SparkEnv.md#create)). Executors have an [RpcEndpointRef](rpc/RpcEndpointRef.md) to the endpoint on the driver.

`coordinatorRef` is used to post an `AskPermissionToCommitOutput` (by executors) to the `OutputCommitCoordinator` (when [canCommit](#canCommit)).

`coordinatorRef` is used to stop the `OutputCommitCoordinator` on the driver (when [stop](#stop)).

## <span id="canCommit"> canCommit

```scala
canCommit(
  stage: Int,
  stageAttempt: Int,
  partition: Int,
  attemptNumber: Int): Boolean
```

`canCommit` creates a `AskPermissionToCommitOutput` message and sends it (asynchronously) to the [OutputCommitCoordinator RPC Endpoint](#coordinatorRef).

`canCommit` is used when:

* `SparkHadoopMapRedUtil` is requested to `commitTask` (with `spark.hadoop.outputCommitCoordination.enabled` configuration property enabled)
* `DataWritingSparkTask` ([Spark SQL]({{ book.spark_sql }}/DataWritingSparkTask)) utility is used to `run`

## <span id="handleAskPermissionToCommit"> handleAskPermissionToCommit

```scala
handleAskPermissionToCommit(
  stage: Int,
  stageAttempt: Int,
  partition: Int,
  attemptNumber: Int): Boolean
```

`handleAskPermissionToCommit`...FIXME

`handleAskPermissionToCommit` is used when:

* `OutputCommitCoordinatorEndpoint` is requested to handle a `AskPermissionToCommitOutput` message (that happens after it was sent out in [canCommit](#canCommit))

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.OutputCommitCoordinator` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.OutputCommitCoordinator=ALL
```

Refer to [Logging](spark-logging.md).
