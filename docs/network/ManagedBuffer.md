# ManagedBuffer

`ManagedBuffer` is the <<contract, abstraction>> of <<extensions, FIXMEs>> that <<FIXME, FIXME>>.

== [[contract]] Contract

[cols="30m,70",options="header",width="100%"]
|===
| Method
| Description

| convertToNetty
a| [[convertToNetty]]

[source, java]
----
Object convertToNetty()
----

Used exclusively when `MessageEncoder` is requested to `encode` a message

| createInputStream
a| [[createInputStream]]

[source, java]
----
InputStream createInputStream()
----

Used exclusively when `ShuffleBlockFetcherIterator` is requested to storage:ShuffleBlockFetcherIterator.md#next[retrieve the next element]

| nioByteBuffer
a| [[nioByteBuffer]]

[source, java]
----
ByteBuffer nioByteBuffer()
----

Used when...FIXME

| release
a| [[release]]

[source, java]
----
ManagedBuffer release()
----

Used when...FIXME

| retain
a| [[retain]]

[source, java]
----
ManagedBuffer retain()
----

Used when:

* `MessageWithHeader` is requested to `retain`

* `ShuffleBlockFetcherIterator` is requested to storage:ShuffleBlockFetcherIterator.md#sendRequest[send a remote shuffle block fetch request] and storage:ShuffleBlockFetcherIterator.md#fetchLocalBlocks[fetchLocalBlocks]

| size
a| [[size]]

[source, java]
----
long size()
----

Number of bytes of the data

Used when...FIXME

|===

== [[implementations]] Available ManagedBuffers

[cols="30m,70",options="header",width="100%"]
|===
| ManagedBuffer
| Description

| BlockManagerManagedBuffer
| [[BlockManagerManagedBuffer]]

| EncryptedManagedBuffer
| [[EncryptedManagedBuffer]]

| FileSegmentManagedBuffer
| [[FileSegmentManagedBuffer]]

| NettyManagedBuffer
| [[NettyManagedBuffer]]

| NioManagedBuffer
| [[NioManagedBuffer]]

|===
