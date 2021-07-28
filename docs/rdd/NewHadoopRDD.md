== [[NewHadoopRDD]] NewHadoopRDD

`NewHadoopRDD` is an rdd:index.md[RDD] of `K` keys and `V` values.

<<creating-instance, `NewHadoopRDD` is created>> when:

* `SparkContext.newAPIHadoopFile`
* `SparkContext.newAPIHadoopRDD`
* (indirectly) `SparkContext.binaryFiles`
* (indirectly) `SparkContext.wholeTextFiles`

NOTE: `NewHadoopRDD` is the base RDD of `BinaryFileRDD` and `WholeTextFileRDD`.

=== [[getPreferredLocations]] `getPreferredLocations` Method

CAUTION: FIXME

=== [[creating-instance]] Creating NewHadoopRDD Instance

`NewHadoopRDD` takes the following when created:

* [[sc]] SparkContext.md[]
* [[inputFormatClass]] HDFS' `InputFormat[K, V]`
* [[keyClass]] `K` class name
* [[valueClass]] `V` class name
* [[_conf]] transient HDFS' `Configuration`

`NewHadoopRDD` initializes the <<internal-registries, internal registries and counters>>.
