---
tags:
  - DeveloperApi
---

# SparkPlugin

`SparkPlugin` is an [abstraction](#contract) of custom extensions for Spark applications.

## Contract

### <span id="driverPlugin"> Driver-side Component

```java
DriverPlugin driverPlugin()
```

Used when:

* `DriverPluginContainer` is [created](DriverPluginContainer.md#driverPlugins)

### <span id="executorPlugin"> Executor-side Component

```java
ExecutorPlugin executorPlugin()
```

Used when:

* `ExecutorPluginContainer` is [created](ExecutorPluginContainer.md#executorPlugins)
