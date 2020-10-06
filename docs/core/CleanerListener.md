= CleanerListener

*CleanerListener* is an abstraction of listeners that can be core:ContextCleaner.md#attachListener[registered with ContextCleaner] to be informed when <<rddCleaned, RDDs>>, <<broadcastCleaned, broadcasts>>, <<shuffleCleaned, shuffles>>, <<accumCleaned, accumulators>> and <<checkpointCleaned, checkpointed RDDs>> are cleaned.

== [[rddCleaned]] rddCleaned Callback Method

[source, scala]
----
rddCleaned(
  rddId: Int): Unit
----

rddCleaned is used when...FIXME

== [[broadcastCleaned]] broadcastCleaned Callback Method

[source, scala]
----
broadcastCleaned(
  broadcastId: Long): Unit
----

broadcastCleaned is used when...FIXME

== [[shuffleCleaned]] shuffleCleaned Callback Method

[source, scala]
----
shuffleCleaned(
  shuffleId: Int,
  blocking: Boolean): Unit
----

shuffleCleaned is used when...FIXME

== [[accumCleaned]] accumCleaned Callback Method

[source, scala]
----
accumCleaned(
  accId: Long): Unit
----

accumCleaned is used when...FIXME

== [[checkpointCleaned]] checkpointCleaned Callback Method

[source, scala]
----
checkpointCleaned(
  rddId: Long): Unit
----

checkpointCleaned is used when...FIXME
