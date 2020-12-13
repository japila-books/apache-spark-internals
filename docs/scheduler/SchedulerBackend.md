# SchedulerBackend

`SchedulerBackend` is an [abstraction](#contract) of [task scheduling backends](#implementations) that can [revive resource offers](#reviveOffers) from cluster managers.

`SchedulerBackend` abstraction allows `TaskSchedulerImpl` to use variety of cluster managers (with their own resource offers and task scheduling modes).

!!! note
    Being a scheduler backend system assumes a [Apache Mesos](http://mesos.apache.org/)-like scheduling model in which "an application" gets **resource offers** as machines become available so it is possible to launch tasks on them. Once required resource allocation is obtained, the scheduler backend can start executors.

## Contract

### <span id="applicationAttemptId"> applicationAttemptId

```scala
applicationAttemptId(): Option[String]
```

**Execution attempt ID** of this Spark application

Default: `None` (undefined)

Used when:

* `TaskSchedulerImpl` is requested for the [execution attempt ID of a Spark application](TaskSchedulerImpl.md#applicationAttemptId)

### <span id="applicationId"><span id="appId"> applicationId

```scala
applicationId(): String
```

**Unique identifier** of this Spark application

Default: `spark-application-[currentTimeMillis]`

Used when:

* `TaskSchedulerImpl` is requested for the [unique identifier of a Spark application](TaskSchedulerImpl.md#applicationId)

### <span id="defaultParallelism"> Default Parallelism

```scala
defaultParallelism(): Int
```

**Default parallelism**, i.e. a hint for the number of tasks in stages while sizing jobs

Used when:

* `TaskSchedulerImpl` is requested for the [default parallelism](TaskSchedulerImpl.md#defaultParallelism)

### <span id="getDriverAttributes"> getDriverAttributes

```scala
getDriverAttributes: Option[Map[String, String]]
```

Default: `None`

Used when:

* `SparkContext` is requested to [postApplicationStart](../SparkContext.md#postApplicationStart)

### <span id="getDriverLogUrls"> getDriverLogUrls

```scala
getDriverLogUrls: Option[Map[String, String]]
```

**Driver log URLs**

Default: `None` (undefined)

Used when:

* `SparkContext` is requested to [postApplicationStart](../SparkContext.md#postApplicationStart)

### <span id="isReady"> isReady

```scala
isReady(): Boolean
```

Controls whether this `SchedulerBackend` is ready (`true`) or not (`false`)

Default: `true`

Used when:

* `TaskSchedulerImpl` is requested to [wait until scheduling backend is ready](TaskSchedulerImpl.md#waitBackendReady)

### <span id="killTask"> Killing Task

```scala
killTask(
  taskId: Long,
  executorId: String,
  interruptThread: Boolean,
  reason: String): Unit
```

Kills a given task

Default: `UnsupportedOperationException`

Used when:

* `TaskSchedulerImpl` is requested to [killTaskAttempt](TaskSchedulerImpl.md#killTaskAttempt) and [killAllTaskAttempts](TaskSchedulerImpl.md#killAllTaskAttempts)
* `TaskSetManager` is requested to [handle a successful task attempt](TaskSetManager.md#handleSuccessfulTask)

### <span id="maxNumConcurrentTasks"> maxNumConcurrentTasks

```scala
maxNumConcurrentTasks(): Int
```

**Maximum number of concurrent tasks** that can currently be launched

Used when:

* `SparkContext` is requested to [maxNumConcurrentTasks](../SparkContext.md#maxNumConcurrentTasks)

### <span id="reviveOffers"> reviveOffers

```scala
reviveOffers(): Unit
```

Handles resource allocation offers (from the scheduling system)

Used when `TaskSchedulerImpl` is requested to:

* [Submit tasks (from a TaskSet)](TaskSchedulerImpl.md#submitTasks)

* [Handle a task status update](TaskSchedulerImpl.md#statusUpdate)

* [Notify the TaskSetManager that a task has failed](TaskSchedulerImpl.md#handleFailedTask)

* [Check for speculatable tasks](TaskSchedulerImpl.md#checkSpeculatableTasks)

* [Handle a lost executor event](TaskSchedulerImpl.md#executorLost)

### <span id="start"> Starting SchedulerBackend

```scala
start(): Unit
```

Starts this `SchedulerBackend`

Used when:

* `TaskSchedulerImpl` is requested to [start](TaskSchedulerImpl.md#start)

### <span id="stop"> stop

```scala
stop(): Unit
```

Stops this `SchedulerBackend`

Used when:

* `TaskSchedulerImpl` is requested to [stop](TaskSchedulerImpl.md#stop)

## Implementations

* [CoarseGrainedSchedulerBackend](CoarseGrainedSchedulerBackend.md)
* [LocalSchedulerBackend](../local/LocalSchedulerBackend.md)
* MesosFineGrainedSchedulerBackend
