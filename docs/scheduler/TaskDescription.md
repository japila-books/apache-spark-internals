# TaskDescription

`TaskDescription` is a metadata of a [Task](Task.md).

## Creating Instance

`TaskDescription` takes the following to be created:

* <span id="taskId"> Task ID
* <span id="attemptNumber"> Task attempt number
* <span id="executorId"> Executor ID
* [Task name](#name)
* <span id="index"> Task index (within the [TaskSet](TaskSet.md))
* <span id="partitionId"> Partition ID
* <span id="addedFiles"> Added files (as `Map[String, Long]`)
* <span id="addedJars"> Added JAR files (as `Map[String, Long]`)
* <span id="properties"> `Properties`
* <span id="resources"> Resources (`Map[String, ResourceInformation]`)
* <span id="serializedTask"> Serialized task (as `ByteBuffer`)

`TaskDescription` is created when:

* `TaskSetManager` is requested to [find a task ready for execution (given a resource offer)](TaskSetManager.md#resourceOffer)

## <span id="toString"> Text Representation

```scala
toString: String
```

`toString` uses the [taskId](#taskId) and [index](#index) as follows:

```text
TaskDescription(TID=[taskId], index=[index])
```

## <span id="decode"> Decoding TaskDescription (from Serialized Format)

```scala
decode(
  byteBuffer: ByteBuffer): TaskDescription
```

`decode` simply decodes (<<creating-instance, creates>>) a `TaskDescription` from the serialized format (`ByteBuffer`).

Internally, `decode`...FIXME

`decode` is used when:

* `CoarseGrainedExecutorBackend` is requested to CoarseGrainedExecutorBackend.md#LaunchTask[handle a LaunchTask message]

* Spark on Mesos' `MesosExecutorBackend` is requested to spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md#launchTask[launch a task]

## <span id="encode"> Encoding TaskDescription (to Serialized Format)

```scala
encode(
  taskDescription: TaskDescription): ByteBuffer
```

`encode` simply encodes the `TaskDescription` to a serialized format (`ByteBuffer`).

Internally, `encode`...FIXME

`encode` is used when:

* `DriverEndpoint` (of `CoarseGrainedSchedulerBackend`) is requested to [launchTasks](DriverEndpoint.md#launchTasks)

## <span id="name"> Task Name

The [name](#name) of the task is of the format:

```text
task [taskID] in stage [taskSetID]
```
