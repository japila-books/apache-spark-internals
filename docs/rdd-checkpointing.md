# RDD Checkpointing

*RDD Checkpointing* is a process of truncating rdd:spark-rdd-lineage.md[RDD lineage graph] and saving it to a reliable distributed (HDFS) or local file system.

There are two types of checkpointing:

* <<reliable-checkpointing, reliable>> - RDD checkpointing that saves the actual intermediate RDD data to a reliable distributed file system (e.g. Hadoop DFS)
* <<local-checkpointing, local>> - RDD checkpointing that saves the data to a local file system

It's up to a Spark application developer to decide when and how to checkpoint using `RDD.checkpoint()` method.

Before checkpointing is used, a Spark developer has to set the checkpoint directory using `SparkContext.setCheckpointDir(directory: String)` method.

== [[reliable-checkpointing]] Reliable Checkpointing

You call `SparkContext.setCheckpointDir(directory: String)` to set the *checkpoint directory* - the directory where RDDs are checkpointed. The `directory` must be a HDFS path if running on a cluster. The reason is that the driver may attempt to reconstruct the checkpointed RDD from its own local file system, which is incorrect because the checkpoint files are actually on the executor machines.

You mark an RDD for checkpointing by calling `RDD.checkpoint()`. The RDD will be saved to a file inside the checkpoint directory and all references to its parent RDDs will be removed. This function has to be called before any job has been executed on this RDD.

NOTE: It is strongly recommended that a checkpointed RDD is persisted in memory, otherwise saving it on a file will require recomputation.

When an action is called on a checkpointed RDD, the following INFO message is printed out in the logs:

```
Done checkpointing RDD 5 to [path], new parent is RDD [id]
```

== [[local-checkpointing]] Local Checkpointing

rdd:RDD.md#localCheckpoint[localCheckpoint] allows to truncate rdd:spark-rdd-lineage.md[RDD lineage graph] while skipping the expensive step of replicating the materialized data to a reliable distributed file system.

This is useful for RDDs with long lineages that need to be truncated periodically, e.g. GraphX.

Local checkpointing trades fault-tolerance for performance.

NOTE: The checkpoint directory set through `SparkContext.setCheckpointDir` is not used.

== [[demo]] Demo

[source,plaintext]
----
val rdd = sc.parallelize(0 to 9)

scala> rdd.checkpoint
org.apache.spark.SparkException: Checkpoint directory has not been set in the SparkContext
  at org.apache.spark.rdd.RDD.checkpoint(RDD.scala:1599)
  ... 49 elided

sc.setCheckpointDir("/tmp/rdd-checkpoint")

// Creates a subdirectory for this SparkContext
$ ls /tmp/rdd-checkpoint/
fc21e1d1-3cd9-4d51-880f-58d1dd07f783

// Mark the RDD to checkpoint at the earliest action
rdd.checkpoint

scala> println(rdd.getCheckpointFile)
Some(file:/tmp/rdd-checkpoint/fc21e1d1-3cd9-4d51-880f-58d1dd07f783/rdd-2)

scala> println(ns.id)
2

scala> println(rdd.getNumPartitions)
16

rdd.count

// Check out the checkpoint directory
// You should find a directory for the checkpointed RDD, e.g. rdd-2
// The number of part-000* files is exactly the number of partitions
$ ls -ltra /tmp/rdd-checkpoint/fc21e1d1-3cd9-4d51-880f-58d1dd07f783/rdd-2/part-000* | wc -l
      16
----
