= TaskDescription

[[creating-instance]]
`TaskDescription` is a metadata of a Task.md[task] with the following properties:

* [[taskId]] Task ID
* [[attemptNumber]] Task attempt number
* [[executorId]] Executor ID
* [[name]] Task name
* [[index]] Task index (within the TaskSet.md[TaskSet])
* [[addedFiles]] Added files (as `Map[String, Long]`)
* [[addedJars]] Added JAR files (as `Map[String, Long]`)
* [[properties]] `Properties`
* [[serializedTask]] Serialized task (as `ByteBuffer`)

The <<name, name>> of the task is of the format:

```
task [taskID] in stage [taskSetID]
```

`TaskDescription` is <<creating-instance, created>> exclusively when `TaskSetManager` is requested to TaskSetManager.md#resourceOffer[find a task ready for execution (given a resource offer)].

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

* `CoarseGrainedExecutorBackend` is requested to CoarseGrainedExecutorBackend.md#LaunchTask[handle a LaunchTask message]

* Spark on Mesos' `MesosExecutorBackend` is requested to spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md#launchTask[launch a task]
====

== [[encode]] Encoding TaskDescription (to Serialized Format)

[source, scala]
----
encode(taskDescription: TaskDescription): ByteBuffer
----

`encode` simply encodes the `TaskDescription` to a serialized format (`ByteBuffer`).

Internally, `encode`...FIXME

`encode` is used when:

* `DriverEndpoint` (of `CoarseGrainedSchedulerBackend`) is requested to [launchTasks](DriverEndpoint.md#launchTasks)
