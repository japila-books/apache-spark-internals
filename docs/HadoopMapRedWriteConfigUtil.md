# HadoopMapRedWriteConfigUtil

`HadoopMapRedWriteConfigUtil` is a [HadoopWriteConfigUtil](HadoopWriteConfigUtil.md) for [RDD.saveAsHadoopDataset](rdd/PairRDDFunctions.md#saveAsHadoopDataset) operator.

## Creating Instance

`HadoopMapRedWriteConfigUtil` takes the following to be created:

* <span id="conf"> `SerializableJobConf`

`HadoopMapRedWriteConfigUtil` is created when:

* `PairRDDFunctions` is requested to [saveAsHadoopDataset](rdd/PairRDDFunctions.md#saveAsHadoopDataset)

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.io.HadoopMapRedWriteConfigUtil` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.HadoopMapRedWriteConfigUtil.name = org.apache.spark.internal.io.HadoopMapRedWriteConfigUtil
logger.HadoopMapRedWriteConfigUtil.level = all
```

Refer to [Logging](spark-logging.md).
