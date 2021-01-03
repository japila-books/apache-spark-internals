# LoggingPodStatusWatcherImpl

`LoggingPodStatusWatcherImpl` is a [LoggingPodStatusWatcher](LoggingPodStatusWatcher.md) that monitors and logs the application status.

## Creating Instance

`LoggingPodStatusWatcherImpl` takes the following to be created:

* <span id="conf"> [KubernetesDriverConf](KubernetesDriverConf.md)

`LoggingPodStatusWatcherImpl` is created when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)

## <span id="eventReceived"> eventReceived

```scala
eventReceived(
  action: Action,
  pod: Pod): Unit
```

`eventReceived` is part of the Kubernetes' `Watcher` abstraction.

`eventReceived` brances off based on the given `Action`:

* For `DELETED` or `ERROR` actions, `eventReceived` [closeWatch](#closeWatch)

* For any other actions, [logLongStatus](#logLongStatus) followed by [closeWatch](#closeWatch) if [hasCompleted](#hasCompleted).

### <span id="logLongStatus"> logLongStatus

```scala
logLongStatus(): Unit
```

`logLongStatus` prints out the following INFO message to the logs:

```text
State changed, new state: [formatPodState|unknown]
```

### <span id="hasCompleted"> hasCompleted

```scala
hasCompleted(): Boolean
```

`hasCompleted` is `true` when the [phase](#phase) is `Succeeded` or `Failed`.

`hasCompleted` is used when:

* `LoggingPodStatusWatcherImpl` is requested to [eventReceived](#eventReceived) (when an action is neither `DELETED` nor `ERROR`)

## <span id="podCompleted"> podCompleted Flag

`LoggingPodStatusWatcherImpl` turns `podCompleted` off when [created](#creating-instance).

Until `podCompleted` is on, `LoggingPodStatusWatcherImpl` waits the [spark.kubernetes.report.interval](configuration-properties.md#spark.kubernetes.report.interval) configuration property and prints out the following INFO message to the logs:

```text
Application status for [appId] (phase: [phase])
```

`podCompleted` turns [podCompleted](#podCompleted) on when [closeWatch](#closeWatch).

## <span id="closeWatch"> closeWatch

```scala
closeWatch(): Unit
```

`closeWatch` turns [podCompleted](#podCompleted) on.

`closeWatch` is used when:

* `LoggingPodStatusWatcherImpl` is requested to [eventReceived](#eventReceived) and [onClose](#onClose)

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.k8s.submit.LoggingPodStatusWatcherImpl` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.k8s.submit.LoggingPodStatusWatcherImpl=ALL
```

Refer to [Logging](../spark-logging.md).
