== [[LiveEntity]] LiveEntity

`LiveEntity` is the <<contract, contract>> of a live entity in Spark that...FIXME

[[contract]]
[source, scala]
----
package org.apache.spark.status

abstract class LiveEntity {
  // only required methods that have no implementation
  // the others follow
  protected def doUpdate(): Any
}
----

NOTE: `LiveEntity` is a `private[spark]` contract.

.LiveEntity Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `doUpdate`
| [[doUpdate]] Used exclusivey when `LiveEntity` is requested to <<write, write>>.
|===

[[lastWriteTime]]
`LiveEntity` tracks the last <<write, write>> time (in `lastWriteTime` internal registry).

=== [[write]] `write` Method

[source, scala]
----
write(store: ElementTrackingStore, now: Long, checkTriggers: Boolean = false): Unit
----

`write` requests the input `ElementTrackingStore` to xref:core:ElementTrackingStore.adoc#write[write] the <<doUpdate, updated>> value.

In the end, `write` records the time in the <<lastWriteTime, lastWriteTime>>.

[NOTE]
====
`write` is used when:

. AppStatusListener is requested to xref:core:AppStatusListener.adoc#update[update]

. SQLAppStatusListener is created (and registers a flush trigger) and requested to `update`
====
