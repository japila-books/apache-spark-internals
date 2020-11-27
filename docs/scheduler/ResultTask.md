# ResultTask

`ResultTask` is a scheduler:Task.md[Task] that <<runTask, executes a function on the records in a RDD partition>>.

<<creating-instance, `ResultTask` is created>> exclusively when scheduler:DAGScheduler.md#submitMissingTasks[`DAGScheduler` submits missing tasks for a `ResultStage`].

`ResultTask` is created with a <<taskBinary, broadcast variable>> with the RDD and the function to execute it on and the <<partition, partition>>.

[[internal-registries]]
.ResultTask's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[preferredLocs]] `preferredLocs`
| Collection of scheduler:TaskLocation.md[TaskLocations].

Corresponds directly to unique entries in <<locs, locs>> with the only rule that when `locs` is not defined, it is empty, and no task location preferences are defined.

Initialized when <<creating-instance, `ResultTask` is created>>.

Used exclusively when `ResultTask` is requested for <<preferredLocations, preferred locations>>.

|===

## Creating Instance

`ResultTask` takes the following when created:

* `stageId` -- the stage the task is executed for
* `stageAttemptId` -- the stage attempt id
* [[taskBinary]] Broadcast.md[] with the serialized task (as `Array[Byte]`). The broadcast contains of a serialized pair of `RDD` and the function to execute.
* [[partition]] [Partition](../rdd/Partition.md) to compute
* [[locs]] Collection of scheduler:TaskLocation.md[TaskLocations], i.e. preferred locations (executors) to execute the task on
* [[outputId]] `outputId`
* [[localProperties]] local `Properties`
* [[serializedTaskMetrics]] The stage's serialized executor:TaskMetrics.md[] (as `Array[Byte]`)
* [[jobId]] (optional) spark-scheduler-ActiveJob.md[Job] id
* [[appId]] (optional) Application id
* [[appAttemptId]] (optional) Application attempt id

`ResultTask` initializes the <<internal-registries, internal registries and counters>>.

=== [[preferredLocations]] `preferredLocations` Method

[source, scala]
----
preferredLocations: Seq[TaskLocation]
----

NOTE: `preferredLocations` is part of scheduler:Task.md#contract[Task contract].

`preferredLocations` simply returns <<preferredLocs, preferredLocs>> internal property.

=== [[runTask]] Deserialize RDD and Function (From Broadcast) and Execute Function (on RDD Partition) -- `runTask` Method

[source, scala]
----
runTask(context: TaskContext): U
----

NOTE: `U` is the type of a result as defined when <<creating-instance, `ResultTask` is created>>.

`runTask` deserializes a RDD and a function from the <<taskBinary, broadcast>> and then executes the function (on the records from the RDD <<partition, partition>>).

NOTE: `runTask` is part of scheduler:Task.md#contract[Task contract] to run a task.

Internally, `runTask` starts by tracking the time required to deserialize a RDD and a function to execute.

`runTask` serializer:Serializer.md#newInstance[creates a new closure `Serializer`].

NOTE: `runTask` uses core:SparkEnv.md#closureSerializer[`SparkEnv` to access the current closure `Serializer`].

`runTask` serializer:Serializer.md#deserialize[requests the closure `Serializer` to deserialize an `RDD` and the function to execute] (from <<taskBinary, taskBinary>> broadcast).

NOTE: <<taskBinary, taskBinary>> broadcast is defined when <<creating-instance, `ResultTask` is created>>.

`runTask` records scheduler:Task.md#_executorDeserializeTime[_executorDeserializeTime] and scheduler:Task.md#_executorDeserializeCpuTime[_executorDeserializeCpuTime] properties.

In the end, `runTask` executes the function (passing in the input `context` and the rdd:index.md#iterator[records from `partition` of the RDD]).

NOTE: `partition` to use to access the records in a deserialized RDD is defined when <<creating-instance, `ResultTask` was created>>.
