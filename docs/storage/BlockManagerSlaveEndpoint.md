# BlockManagerSlaveEndpoint

**BlockManagerSlaveEndpoint** is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) for [BlockManager](BlockManager.md#slaveEndpoint).

## Creating Instance

BlockManagerSlaveEndpoint takes the following to be created:

* [[rpcEnv]] rpc:RpcEnv.md[]
* [[blockManager]] Parent BlockManager.md[]
* [[mapOutputTracker]] scheduler:MapOutputTracker.md[]

BlockManagerSlaveEndpoint is created for BlockManager.md#slaveEndpoint[BlockManager] (and registered under the name *BlockManagerEndpoint[ID]*).

== [[messages]] Messages

=== [[GetBlockStatus]] GetBlockStatus

[source, scala]
----
GetBlockStatus(
  blockId: BlockId,
  askSlaves: Boolean = true)
----

When received, BlockManagerSlaveEndpoint requests the <<blockManager, BlockManager>> for the BlockManager.md#getStatus[status of a given block] (by BlockId.md[]) and sends it back to a sender.

Posted when...FIXME

=== [[GetMatchingBlockIds]] GetMatchingBlockIds

[source, scala]
----
GetMatchingBlockIds(
  filter: BlockId => Boolean,
  askSlaves: Boolean = true)
----

When received, BlockManagerSlaveEndpoint requests the <<blockManager, BlockManager>> to storage:BlockManager.md#getMatchingBlockIds[find IDs of existing blocks for a given filter] and sends them back to a sender.

Posted when...FIXME

=== [[RemoveBlock]] RemoveBlock

[source, scala]
----
RemoveBlock(
  blockId: BlockId)
----

When received, BlockManagerSlaveEndpoint prints out the following DEBUG message to the logs:

[source,plaintext]
----
removing block [blockId]
----

BlockManagerSlaveEndpoint then <<removeBlock, BlockManager to remove `blockId` block>>.

When the computation is successful, you should see the following DEBUG in the logs:

```
Done removing block [blockId], response is [response]
```

And `true` response is sent back. You should see the following DEBUG in the logs:

```
Sent response: true to [senderAddress]
```

In case of failure, you should see the following ERROR in the logs and the stack trace.

```
Error in removing block [blockId]
```

=== [[RemoveBroadcast]] RemoveBroadcast

[source, scala]
----
RemoveBroadcast(
  broadcastId: Long,
  removeFromDriver: Boolean = true)
----

When received, BlockManagerSlaveEndpoint prints out the following DEBUG message to the logs:

[source,plaintext]
----
removing broadcast [broadcastId]
----

It then calls <<removeBroadcast, BlockManager to remove the `broadcastId` broadcast>>.

When the computation is successful, you should see the following DEBUG in the logs:

```
Done removing broadcast [broadcastId], response is [response]
```

And the result is sent back. You should see the following DEBUG in the logs:

```
Sent response: [response] to [senderAddress]
```

In case of failure, you should see the following ERROR in the logs and the stack trace.

```
Error in removing broadcast [broadcastId]
```

=== [[RemoveRdd]] RemoveRdd

[source, scala]
----
RemoveRdd(
  rddId: Int)
----

When received, BlockManagerSlaveEndpoint prints out the following DEBUG message to the logs:

```
removing RDD [rddId]
```

It then calls <<removeRdd, BlockManager to remove `rddId` RDD>>.

NOTE: Handling `RemoveRdd` messages happens on a separate thread. See <<asyncThreadPool, BlockManagerSlaveEndpoint Thread Pool>>.

When the computation is successful, you should see the following DEBUG in the logs:

```
Done removing RDD [rddId], response is [response]
```

And the number of blocks removed is sent back. You should see the following DEBUG in the logs:

```
Sent response: [#blocks] to [senderAddress]
```

In case of failure, you should see the following ERROR in the logs and the stack trace.

```
Error in removing RDD [rddId]
```

=== [[RemoveShuffle]] RemoveShuffle

[source, scala]
----
RemoveShuffle(
  shuffleId: Int)
----

When received, BlockManagerSlaveEndpoint prints out the following DEBUG message to the logs:

```
removing shuffle [shuffleId]
```

If scheduler:MapOutputTracker.md[MapOutputTracker] was given (when the RPC endpoint was created), it calls scheduler:MapOutputTracker.md#unregisterShuffle[MapOutputTracker to unregister the `shuffleId` shuffle].

It then calls shuffle:ShuffleManager.md#unregisterShuffle[ShuffleManager to unregister the `shuffleId` shuffle].

NOTE: Handling `RemoveShuffle` messages happens on a separate thread. See <<asyncThreadPool, BlockManagerSlaveEndpoint Thread Pool>>.

When the computation is successful, you should see the following DEBUG in the logs:

```
Done removing shuffle [shuffleId], response is [response]
```

And the result is sent back. You should see the following DEBUG in the logs:

```
Sent response: [response] to [senderAddress]
```

In case of failure, you should see the following ERROR in the logs and the stack trace.

```
Error in removing shuffle [shuffleId]
```

Posted when BlockManagerMaster.md#removeShuffle[BlockManagerMaster] and storage:BlockManagerMasterEndpoint.md#removeShuffle[BlockManagerMasterEndpoint] are requested to remove all blocks of a shuffle.

=== [[ReplicateBlock]] ReplicateBlock

[source, scala]
----
ReplicateBlock(
  blockId: BlockId,
  replicas: Seq[BlockManagerId],
  maxReplicas: Int)
----

When received, BlockManagerSlaveEndpoint...FIXME

Posted when...FIXME

=== [[TriggerThreadDump]] TriggerThreadDump

When received, BlockManagerSlaveEndpoint is requested for the thread info for all live threads with stack trace and synchronization information.

== [[asyncThreadPool]][[asyncExecutionContext]] block-manager-slave-async-thread-pool Thread Pool

BlockManagerSlaveEndpoint creates a thread pool of maximum 100 daemon threads with *block-manager-slave-async-thread-pool* thread prefix (using {java-javadoc-url}/java/util/concurrent/ThreadPoolExecutor.html[java.util.concurrent.ThreadPoolExecutor]).

BlockManagerSlaveEndpoint uses the thread pool (as a Scala implicit value) when requested to <<doAsync, doAsync>> to communicate in a non-blocking, asynchronous way.

The thread pool is shut down when BlockManagerSlaveEndpoint is requested to <<onStop, stop>>.

The reason for the async thread pool is that the block-related operations might take quite some time and to release the main RPC thread other threads are spawned to talk to the external services and pass responses on to the clients.

== [[doAsync]] doAsync Internal Method

[source,scala]
----
doAsync[T](
  actionMessage: String,
  context: RpcCallContext)(
  body: => T)
----

doAsync creates a Scala Future to execute the following asynchronously (i.e. on a separate thread from the <<asyncThreadPool, Thread Pool>>):

. Prints out the given `actionMessage` as a DEBUG message to the logs

. Executes the given `body`

When completed successfully, doAsync prints out the following DEBUG messages to the logs and requests the given RpcCallContext to reply the response to the sender.

[source,plaintext]
----
Done [actionMessage], response is [response]
Sent response: [response] to [senderAddress]
----

In case of a failure, doAsync prints out the following ERROR message to the logs and requests the given RpcCallContext to send the failure to the sender.

[source,plaintext]
----
Error in [actionMessage]
----

doAsync is used when BlockManagerSlaveEndpoint is requested to handle <<RemoveBlock, RemoveBlock>>, <<RemoveRdd, RemoveRdd>>, <<RemoveShuffle, RemoveShuffle>> and <<RemoveBroadcast, RemoveBroadcast>> messages.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManagerSlaveEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.BlockManagerSlaveEndpoint=ALL
----

Refer to spark-logging.md[Logging].
