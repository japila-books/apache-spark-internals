= BlockTransferService

*BlockTransferService* is an <<contract, extension>> of the xref:storage:ShuffleClient.adoc[] abstraction for <<implementations, shuffle clients>> that can <<fetchBlocks, fetch>> and <<uploadBlock, upload>> blocks of data synchronously or asynchronously.

BlockTransferService is a networking service available by a <<hostName, host name>> and a <<port, port>>.

BlockTransferService was introduced in https://issues.apache.org/jira/browse/SPARK-3019[SPARK-3019 Pluggable block transfer interface (BlockTransferService)].

== [[contract]] Contract

=== [[close]] close

[source,scala]
----
close(): Unit
----

Used when BlockManager is requested to xref:storage:BlockManager.adoc#stop[stop]

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

fetchBlocks is part of the xref:storage:ShuffleClient.adoc#fetchBlocks[ShuffleClient] abstraction.

Used when BlockTransferService is requested to <<fetchBlockSync, fetch only one block (in a blocking fashion)>>

=== [[hostName]] hostName

[source,scala]
----
hostName: String
----

Used when BlockManager is requested to xref:storage:BlockManager.adoc#initialize[initialize]

=== [[init]] init

[source,scala]
----
init(
  blockDataManager: BlockDataManager): Unit
----

Used when BlockManager is requested to xref:storage:BlockManager.adoc#initialize[initialize] (with the xref:storage:BlockDataManager.adoc[] being the BlockManager itself)

=== [[port]] port

[source,scala]
----
port: Int
----

Used when BlockManager is requested to xref:storage:BlockManager.adoc#initialize[initialize]

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

xref:storage:NettyBlockTransferService.adoc[] is the default and only known BlockTransferService.

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

Synchronous (and hence blocking) fetchBlockSync to fetch one block `blockId` (that corresponds to the xref:storage:ShuffleClient.adoc[] parent's asynchronous xref:storage:ShuffleClient.adoc#fetchBlocks[fetchBlocks]).

fetchBlockSync is a mere wrapper around xref:storage:ShuffleClient.adoc#fetchBlocks[fetchBlocks] to fetch one `blockId` block that waits until the fetch finishes.

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

uploadBlockSync is used when BlockManager is requested to xref:storage:BlockManager.adoc#replicate[replicate] (when a xref:storage:StorageLevel.adoc[replication level is greater than 1]).
