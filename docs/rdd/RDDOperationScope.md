# RDDOperationScope

## withScope { #withScope }

```scala
withScope[T](
  sc: SparkContext,
  name: String,
  allowNesting: Boolean,
  ignoreParent: Boolean)(
  body: => T): T
withScope[T](
  sc: SparkContext,
  allowNesting: Boolean = false)(
  body: => T): T
```

??? note "name Argument"
    Value | Caller
    ------|-------
    `checkpoint` | [RDD.doCheckpoint](RDD.md#doCheckpoint)
    _Some_ method name | Executed without `name`
    The name of a physical operator (with no `Exec` suffix) | `SparkPlan.executeQuery` ([Spark SQL]({{ book.spark_sql }}/physical-operators/SparkPlan/#executeQuery))

`withScope`...FIXME

---

`withScope` is used when:

* `RDD` is requested to [doCheckpoint](RDD.md#doCheckpoint) and [withScope](RDD.md#withScope) (for most, if not all, `RDD` API operators)
* `SparkContext` is requested to [withScope](../SparkContext.md#withScope) (for most, if not all, `SparkContext` API operators)
* `SparkPlan` ([Spark SQL]({{ book.spark_sql }}/physical-operators/SparkPlan/#executeQuery)) is requested to `executeQuery`
