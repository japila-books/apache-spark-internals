= TaskDescription

[[creating-instance]]
`TaskDescription` is a metadata of a xref:scheduler:Task.adoc[task] with the following properties:

* [[taskId]] Task ID
* [[attemptNumber]] Task attempt number
* [[executorId]] Executor ID
* [[name]] Task name
* [[index]] Task index (within the xref:scheduler:TaskSet.adoc[TaskSet])
* [[addedFiles]] Added files (as `Map[String, Long]`)
* [[addedJars]] Added JAR files (as `Map[String, Long]`)
* [[properties]] `Properties`
* [[serializedTask]] Serialized task (as `ByteBuffer`)

The <<name, name>> of the task is of the format:

```
task [taskID] in stage [taskSetID]
```

`TaskDescription` is <<creating-instance, created>> exclusively when `TaskSetManager` is requested to xref:scheduler:TaskSetManager.adoc#resourceOffer[find a task ready for execution (given a resource offer)].

[[toString]]
The textual representation of a `TaskDescription` is as follows:

```
TaskDescription(TID=[taskId], index=[index])
```

== [[decode]] Decoding TaskDescription (from Serialized Format)

[source, scala]
----
decode(byteBuffer: ByteBuffer): TaskDescription
----

`decode` simply decodes (<<creating-instance, creates>>) a `TaskDescription` from the serialized format (`ByteBuffer`).

Internally, `decode`...FIXME

[NOTE]
====
`decode` is used when:

* `CoarseGrainedExecutorBackend` is requested to xref:CoarseGrainedExecutorBackend.adoc#LaunchTask[handle a LaunchTask message]

* Spark on Mesos' `MesosExecutorBackend` is requested to xref:spark-on-mesos:spark-executor-backends-MesosExecutorBackend.adoc#launchTask[launch a task]
====

== [[encode]] Encoding TaskDescription (to Serialized Format)

[source, scala]
----
encode(taskDescription: TaskDescription): ByteBuffer
----

`encode` simply encodes the `TaskDescription` to a serialized format (`ByteBuffer`).

Internally, `encode`...FIXME

[NOTE]
====
`encode` is used when:

* `DriverEndpoint` (of `CoarseGrainedSchedulerBackend`) is requested to xref:scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.adoc#launchTasks[launchTasks]

* Spark on Mesos' `MesosFineGrainedSchedulerBackend` is requested to `createMesosTask`
====
