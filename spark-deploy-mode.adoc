== Deploy Mode

*Deploy mode* specifies the location of where link:spark-driver.adoc[driver] executes in the link:spark-deployment-environments.adoc[deployment environment].

Deploy mode can be one of the following options:

* `client` (default) - the driver runs on the machine that the Spark application was launched.
* `cluster` - the driver runs on a random node in a cluster.

NOTE: `cluster` deploy mode is only available for link:spark-cluster.adoc[non-local cluster deployments].

You can control the deploy mode of a Spark application using link:spark-submit.adoc#deploy-mode[spark-submit's `--deploy-mode` command-line option] or <<spark.submit.deployMode, `spark.submit.deployMode` Spark property>>.

NOTE: `spark.submit.deployMode` setting can be `client` or `cluster`.

=== [[client]] Client Deploy Mode

CAUTION: FIXME

=== [[cluster]] Cluster Deploy Mode

CAUTION: FIXME

=== [[spark.submit.deployMode]] spark.submit.deployMode

`spark.submit.deployMode` (default: `client`) can be `client` or `cluster`.
