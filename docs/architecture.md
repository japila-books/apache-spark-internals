= Spark Architecture

Spark uses a *master/worker architecture*. There is a spark-driver.md[driver] that talks to a single coordinator called spark-master.md[master] that manages spark-workers.md[workers] in which executor:Executor.md[executors] run.

.Spark architecture
image::driver-sparkcontext-clustermanager-workers-executors.png[align="center"]

The driver and the executors run in their own Java processes. You can run them all on the same (_horizontal cluster_) or separate machines (_vertical cluster_) or in a mixed machine configuration.

.Spark architecture in detail
image::sparkapp-sparkcontext-master-slaves.png[align="center"]

Physical machines are called *hosts* or *nodes*.
