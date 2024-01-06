# HadoopMapReduceWriteConfigUtil

`HadoopMapReduceWriteConfigUtil` is a [HadoopWriteConfigUtil](HadoopWriteConfigUtil.md) for [RDD.saveAsNewAPIHadoopDataset](rdd/PairRDDFunctions.md#saveAsNewAPIHadoopDataset) operator.

## Creating Instance

`HadoopMapReduceWriteConfigUtil` takes the following to be created:

* <span id="conf"> `SerializableConfiguration`

`HadoopMapReduceWriteConfigUtil` is created when:

* `PairRDDFunctions` is requested to [saveAsNewAPIHadoopDataset](rdd/PairRDDFunctions.md#saveAsNewAPIHadoopDataset)

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.io.HadoopMapReduceWriteConfigUtil` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.HadoopMapReduceWriteConfigUtil.name = org.apache.spark.internal.io.HadoopMapReduceWriteConfigUtil
logger.HadoopMapReduceWriteConfigUtil.level = all
```

Refer to [Logging](spark-logging.md).
