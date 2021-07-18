# StandaloneAppClientListener

`StandaloneAppClientListener` is an [abstraction](#contract) of [listeners](#implementations).

## Contract

### <span id="connected"> connected

```scala
connected(
  appId: String): Unit
```

Used when:

* `ClientEndpoint` is requested to [handle a RegisteredApplication message](ClientEndpoint.md#RegisteredApplication)

### <span id="dead"> dead

```scala
dead(
  reason: String): Unit
```

Used when:

* `ClientEndpoint` is requested to [markDead](ClientEndpoint.md#markDead)

### <span id="disconnected"> disconnected

```scala
disconnected(): Unit
```

Used when:

* `ClientEndpoint` is requested to [markDisconnected](ClientEndpoint.md#markDisconnected)

### <span id="executorAdded"> executorAdded

```scala
executorAdded(
  fullId: String,
  workerId: String,
  hostPort: String,
  cores: Int,
  memory: Int): Unit
```

Used when:

* `ClientEndpoint` is requested to [handle a ExecutorAdded message](ClientEndpoint.md#ExecutorAdded)

### <span id="executorDecommissioned"> executorDecommissioned

```scala
executorDecommissioned(
  fullId: String,
  decommissionInfo: ExecutorDecommissionInfo): Unit
```

Used when:

* `ClientEndpoint` is requested to [handle a ExecutorUpdated message](ClientEndpoint.md#ExecutorUpdated)

### <span id="executorRemoved"> executorRemoved

```scala
executorRemoved(
  fullId: String,
  message: String,
  exitStatus: Option[Int],
  workerHost: Option[String]): Unit
```

Used when:

* `ClientEndpoint` is requested to [handle a ExecutorUpdated message](ClientEndpoint.md#ExecutorUpdated)

### <span id="workerRemoved"> workerRemoved

```scala
workerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
```

Used when:

* `ClientEndpoint` is requested to [handle a WorkerRemoved message](ClientEndpoint.md#WorkerRemoved)

## Implementations

* [StandaloneSchedulerBackend](StandaloneSchedulerBackend.md)
