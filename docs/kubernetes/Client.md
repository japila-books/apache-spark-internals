# Client

## Creating Instance

`Client` takes the following to be created:

* <span id="conf"> [KubernetesDriverConf](KubernetesDriverConf.md)
* <span id="builder"> [KubernetesDriverBuilder](KubernetesDriverBuilder.md)
* <span id="kubernetesClient"> Kubernetes' `KubernetesClient`
* <span id="watcher"> [LoggingPodStatusWatcher](LoggingPodStatusWatcher.md)

`Client` is created when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)

## <span id="run"> Running

```scala
run(): Unit
```

`run`...FIXME

`run` is used when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)
