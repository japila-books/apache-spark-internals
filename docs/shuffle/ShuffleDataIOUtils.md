# ShuffleDataIOUtils

## <span id="loadShuffleDataIO"> Loading ShuffleDataIO

```scala
loadShuffleDataIO(
  conf: SparkConf): ShuffleDataIO
```

`loadShuffleDataIO` uses the [spark.shuffle.sort.io.plugin.class](../configuration-properties.md#spark.shuffle.sort.io.plugin.class) configuration property to load the [ShuffleDataIO](ShuffleDataIO.md).

`loadShuffleDataIO` is used when:

* `SparkContext` is [created](../SparkContext.md#shuffleDriverComponents)
* `SortShuffleManager` utility is used to [loadShuffleExecutorComponents](SortShuffleManager.md#loadShuffleExecutorComponents)
