# ResourceUtils

## Registering Task Resource Requests (from SparkConf) { #addTaskResourceRequests }

```scala
addTaskResourceRequests(
  sparkConf: SparkConf,
  treqs: TaskResourceRequests): Unit
```

`addTaskResourceRequests` registers all task resource requests in the given [SparkConf](../SparkConf.md) to the given [TaskResourceRequests](TaskResourceRequests.md).

---

`addTaskResourceRequests` [listResourceIds](#listResourceIds) with `spark.task` component name in the given [SparkConf](../SparkConf.md).

For every [ResourceID](ResourceID.md) discovered, `addTaskResourceRequests` does the following:

1. [Finds all the settings](../SparkConf.md#getAllWithPrefix) with the [confPrefix](ResourceID.md#confPrefix)
1. Looks up `amount` setting (or throws a `SparkException`)
1. [Registers](TaskResourceRequests.md#resource) the [resourceName](ResourceID.md#resourceName) with the `amount` in the given [TaskResourceRequests](TaskResourceRequests.md)

---

`addTaskResourceRequests` is used when:

* `ResourceProfile` is requested for the [default task resource requests](ResourceProfile.md#getDefaultTaskResources)
