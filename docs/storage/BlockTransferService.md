= BlockTransferService

*BlockTransferService* is an <<contract, extension>> of the storage:ShuffleClient.md[] abstraction for <<implementations, shuffle clients>> that can <<fetchBlocks, fetch>> and <<uploadBlock, upload>> blocks of data synchronously or asynchronously.

BlockTransferService is a networking service available by a <<hostName, host name>> and a <<port, port>>.

BlockTransferService was introduced in https://issues.apache.org/jira/browse/SPARK-3019[SPARK-3019 Pluggable block transfer interface (BlockTransferService)].

== [[contract]] Contract

=== [[close]] close

[source,scala]
----
close(): Unit
----

Used when BlockManager is requested to storage:BlockManager.md#stop[stop]

=== [[fetchBlocks]] fetchBlocks

[source,scala]
----
fetchBlocks(
  host: String,
  port: Int,
  execId: String,
  blockIds: Array[String],
  listener: BlockFetchingListener,
  tempFileManager: DownloadFileManager): Unit
----

Fetches a sequence of blocks from a remote node asynchronously

fetchBlocks is part of the storage:ShuffleClient.md#fetchBlocks[ShuffleClient] abstraction.

Used when BlockTransferService is requested to <<fetchBlockSync, fetch only one block (in a blocking fashion)>>

=== [[hostName]] hostName

[source,scala]
----
hostName: String
----

Used when BlockManager is requested to storage:BlockManager.md#initialize[initialize]

=== [[init]] init

[source,scala]
----
init(
  blockDataManager: BlockDataManager): Unit
----

Used when BlockManager is requested to storage:BlockManager.md#initialize[initialize] (with the storage:BlockDataManager.md[] being the BlockManager itself)

=== [[port]] port

[source,scala]
----
port: Int
----

Used when BlockManager is requested to storage:BlockManager.md#initialize[initialize]

=== [[uploadBlock]] uploadBlock

[source,scala]
----
uploadBlock(
  hostname: String,
  port: Int,
  execId: String,
  blockId: BlockId,
  blockData: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Future[Unit]
----

Used when BlockTransferService is requested to <<uploadBlockSync, upload a single block to a remote node (in a blocking fashion)>>

== [[implementations]] BlockTransferServices

storage:NettyBlockTransferService.md[] is the default and only known BlockTransferService.

== [[fetchBlockSync]] fetchBlockSync Method

[source, scala]
----
fetchBlockSync(
  host: String,
  port: Int,
  execId: String,
  blockId: String,
  tempFileManager: TempFileManager): ManagedBuffer
----

fetchBlockSync...FIXME

Synchronous (and hence blocking) fetchBlockSync to fetch one block `blockId` (that corresponds to the storage:ShuffleClient.md[] parent's asynchronous storage:ShuffleClient.md#fetchBlocks[fetchBlocks]).

fetchBlockSync is a mere wrapper around storage:ShuffleClient.md#fetchBlocks[fetchBlocks] to fetch one `blockId` block that waits until the fetch finishes.

fetchBlockSync is used when...FIXME

== [[uploadBlockSync]] Uploading Single Block to Remote Node (Blocking Fashion)

[source, scala]
----
uploadBlockSync(
  hostname: String,
  port: Int,
  execId: String,
  blockId: BlockId,
  blockData: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Unit
----

uploadBlockSync...FIXME

uploadBlockSync is a mere blocking wrapper around <<uploadBlock, uploadBlock>> that waits until the upload finishes.

uploadBlockSync is used when BlockManager is requested to storage:BlockManager.md#replicate[replicate] (when a storage:StorageLevel.md[replication level is greater than 1]).
