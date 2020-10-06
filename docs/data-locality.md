= Data Locality / Placement

Spark relies on _data locality_, aka _data placement_ or _proximity to data source_, that makes Spark jobs sensitive to where the data is located. It is therefore important to have yarn/README.md[Spark running on Hadoop YARN cluster] if the data comes from HDFS.

In yarn/README.md[Spark on YARN] Spark tries to place tasks alongside HDFS blocks.

With HDFS the Spark driver contacts NameNode about the DataNodes (ideally local) containing the various blocks of a file or directory as well as their locations (represented as `InputSplits`), and then schedules the work to the SparkWorkers.

Spark's compute nodes / workers should be running on storage nodes.

Concept of *locality-aware scheduling*.

Spark tries to execute tasks as close to the data as possible to minimize data transfer (over the wire).

.Locality Level in the Spark UI
image::sparkui-stages-locality-level.png[]

There are the following task localities (consult https://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.scheduler.TaskLocality$[org.apache.spark.scheduler.TaskLocality] object):

* `PROCESS_LOCAL`
* `NODE_LOCAL`
* `NO_PREF`
* `RACK_LOCAL`
* `ANY`

Task location can either be a host or a pair of a host and an executor.
