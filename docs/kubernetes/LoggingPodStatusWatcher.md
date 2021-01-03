# LoggingPodStatusWatcher

`LoggingPodStatusWatcher` is an [extension](#contract) of Kubernetes' `Watcher[Pod]` for [pod watchers](#implementations) that can [watchOrStop](#watchOrStop).

`LoggingPodStatusWatcher` is used to create a [Client](Client.md#watcher) when a [KubernetesClientApplication](KubernetesClientApplication.md) is requested to [start](KubernetesClientApplication.md#start).

## Contract

### <span id="watchOrStop"> watchOrStop

```scala
watchOrStop(
  submissionId: String): Unit
```

Used when:

* `Client` is requested to [run](Client.md#run)

## Implementations

* [LoggingPodStatusWatcherImpl](LoggingPodStatusWatcherImpl.md)
