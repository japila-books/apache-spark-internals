# TaskLocation

TaskLocation represents a placement preference of an RDD partition, i.e. a hint of the location to submit scheduler:Task.md[tasks] for execution.

TaskLocations are tracked by scheduler:DAGScheduler.md#cacheLocs[DAGScheduler] for scheduler:DAGScheduler.md#submitMissingTasks[submitting missing tasks of a stage].

TaskLocation is available as scheduler:Task.md#preferredLocations[preferredLocations] of a task.

[[host]]
Every TaskLocation describes the location by host name, but could also use other location-related metadata.

TaskLocations of an RDD and a partition is available using SparkContext.md#getPreferredLocs[SparkContext.getPreferredLocs] method.

??? note "Sealed"
    `TaskLocation` is a Scala `private[spark] sealed` trait so all the available implementations of TaskLocation trait are in a single Scala file.

== [[ExecutorCacheTaskLocation]] ExecutorCacheTaskLocation

ExecutorCacheTaskLocation describes a <<host, host>> and an executor.

ExecutorCacheTaskLocation informs the Scheduler to prefer a given executor, but the next level of preference is any executor on the same host if this is not possible.

== [[HDFSCacheTaskLocation]] HDFSCacheTaskLocation

HDFSCacheTaskLocation describes a <<host, host>> that is cached by HDFS.

Used exclusively when rdd:HadoopRDD.md#getPreferredLocations[HadoopRDD] and rdd:NewHadoopRDD.md#getPreferredLocations[NewHadoopRDD] are requested for their placement preferences (aka _preferred locations_).

== [[HostTaskLocation]] HostTaskLocation

HostTaskLocation describes a <<host, host>> only.
