== [[LauncherBackend]] LauncherBackend

`LauncherBackend` is the <<contract, abstraction>> of <<implementations, launcher backends>> that can <<FIXME, FIXME>>.

[[contract]]
.LauncherBackend Contract (Abstract Methods Only)
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| conf
a| [[conf]]

[source, scala]
----
conf: SparkConf
----

SparkConf.md[]

Used exclusively when `LauncherBackend` is requested to <<connect, connect>> (to access configuration-properties.md#spark.launcher.port[spark.launcher.port] and configuration-properties.md#spark.launcher.secret[spark.launcher.secret] configuration properties)

| onStopRequest
a| [[onStopRequest]]

[source, scala]
----
onStopRequest(): Unit
----

Handles stop requests (to stop the Spark application as gracefully as possible)

Used exclusively when `LauncherBackend` is requested to <<fireStopRequest, fireStopRequest>>

|===

[[creating-instance]]
`LauncherBackend` takes no arguments to be created.

NOTE: `LauncherBackend` is a Scala abstract class and cannot be <<creating-instance, created>> directly. It is created indirectly for the <<implementations, concrete LauncherBackends>>.

[[internal-registries]]
.LauncherBackend's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1m,3",options="header",width="100%"]
|===
| Name
| Description

| _isConnected
a| [[_isConnected]][[isConnected]] Flag that says whether...FIXME (`true`) or not (`false`)

Default: `false`

Used when...FIXME

| clientThread
a| [[clientThread]] Java's https://docs.oracle.com/javase/8/docs/api/java/lang/Thread.html[java.lang.Thread]

Used when...FIXME

| connection
a| [[connection]] `BackendConnection`

Used when...FIXME

| lastState
a| [[lastState]] `SparkAppHandle.State`

Used when...FIXME

|===

[[implementations]]
`LauncherBackend` is <<creating-instance, created>> (as an anonymous class) for the following:

* Spark on YARN's <<yarn/spark-yarn-client.md#launcherBackend, Client>>

* Spark local's <<local/spark-LocalSchedulerBackend.md#launcherBackend, LocalSchedulerBackend>>

* Spark on Mesos' <<spark-mesos/spark-mesos-MesosCoarseGrainedSchedulerBackend.md#launcherBackend, MesosCoarseGrainedSchedulerBackend>>

* Spark Standalone's <<spark-standalone-StandaloneSchedulerBackend.md#launcherBackend, StandaloneSchedulerBackend>>

=== [[close]] Closing -- `close` Method

[source, scala]
----
close(): Unit
----

`close`...FIXME

NOTE: `close` is used when...FIXME

=== [[connect]] Connecting -- `connect` Method

[source, scala]
----
connect(): Unit
----

`connect`...FIXME

[NOTE]
====
`connect` is used when:

* Spark Standalone's `StandaloneSchedulerBackend` is requested to <<spark-standalone-StandaloneSchedulerBackend.md#start, start>> (in `client` deploy mode)

* Spark local's `LocalSchedulerBackend` is <<local/spark-LocalSchedulerBackend.md#, created>>

* Spark on Mesos' `MesosCoarseGrainedSchedulerBackend` is requested to <<spark-mesos/spark-mesos-MesosCoarseGrainedSchedulerBackend.md#start, start>> (in `client` deploy mode)

* Spark on YARN's `Client` is requested to <<yarn/spark-yarn-client.md#submitApplication, submit a Spark application>>
====

=== [[fireStopRequest]] `fireStopRequest` Internal Method

[source, scala]
----
fireStopRequest(): Unit
----

`fireStopRequest`...FIXME

NOTE: `fireStopRequest` is used exclusively when `BackendConnection` is requested to handle a `Stop` message.

=== [[onDisconnected]] Handling Disconnects From Scheduling Backend -- `onDisconnected` Method

[source, scala]
----
onDisconnected(): Unit
----

`onDisconnected` does nothing by default and is expected to be overriden by <<implementations, implementations>>.

NOTE: `onDisconnected` is used when...FIXME

=== [[setAppId]] `setAppId` Method

[source, scala]
----
setAppId(appId: String): Unit
----

`setAppId`...FIXME

NOTE: `setAppId` is used when...FIXME

=== [[setState]] `setState` Method

[source, scala]
----
setState(state: SparkAppHandle.State): Unit
----

`setState`...FIXME

NOTE: `setState` is used when...FIXME
