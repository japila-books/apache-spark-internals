# Configuration Properties of Spark Standalone

## <span id="spark.deploy.spreadOut"> spark.deploy.spreadOut

Controls whether standalone Master should perform round-robin scheduling across the nodes

Default: `true`

## <span id="spark.worker.resourcesFile"><span id="SPARK_WORKER_RESOURCE_FILE"> spark.worker.resourcesFile

**(internal)** Path to a file containing the resources allocated to the worker. The file should be formatted as a JSON array of ResourceAllocation objects. Only used internally in standalone mode.

Default: (undefined)

Used when:

* `LocalSparkCluster` is requested to [start](LocalSparkCluster.md#start)
* `Worker` standalone application is [launched](Worker.md#main)
