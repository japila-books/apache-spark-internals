# SparkConf

Every user program starts with creating an instance of `SparkConf` that holds the spark-deployment-environments.md#master-urls[master URL] to connect to (`spark.master`), the name for your Spark application (that is later displayed in webui:index.md[web UI] and becomes `spark.app.name`) and other Spark properties required for proper runs. The instance of `SparkConf` can be used to create SparkContext.md[SparkContext].

[TIP]
====
Start tools:spark-shell.md[Spark shell] with `--conf spark.logConf=true` to log the effective Spark configuration as INFO when SparkContext is started.

```
$ ./bin/spark-shell --conf spark.logConf=true
...
15/10/19 17:13:49 INFO SparkContext: Running Spark version 1.6.0-SNAPSHOT
15/10/19 17:13:49 INFO SparkContext: Spark configuration:
spark.app.name=Spark shell
spark.home=/Users/jacek/dev/oss/spark
spark.jars=
spark.logConf=true
spark.master=local[*]
spark.repl.class.uri=http://10.5.10.20:64055
spark.submit.deployMode=client
...
```

Use `sc.getConf.toDebugString` to have a richer output once SparkContext has finished initializing.
====

You can query for the values of Spark properties in [Spark shell](tools/spark-shell.md) as follows:

```text
scala> sc.getConf.getOption("spark.local.dir")
res0: Option[String] = None

scala> sc.getConf.getOption("spark.app.name")
res1: Option[String] = Some(Spark shell)

scala> sc.getConf.get("spark.master")
res2: String = local[*]
```

== [[setIfMissing]] setIfMissing Method

CAUTION: FIXME

== [[isExecutorStartupConf]] isExecutorStartupConf Method

CAUTION: FIXME

== [[set]] set Method

CAUTION: FIXME

== Setting up Spark Properties

There are the following places where a Spark application looks for Spark properties (in the order of importance from the least important to the most important):

* `conf/spark-defaults.conf` - the configuration file with the default Spark properties. Read spark-properties.md#spark-defaults-conf[spark-defaults.conf].
* `--conf` or `-c` - the command-line option used by tools:spark-submit.md[spark-submit] (and other shell scripts that use `spark-submit` or `spark-class` under the covers, e.g. `spark-shell`)
* `SparkConf`

== [[default-configuration]] Default Configuration

The default Spark configuration is created when you execute the following code:

[source, scala]
----
import org.apache.spark.SparkConf
val conf = new SparkConf
----

It simply loads `spark.*` system properties.

You can use `conf.toDebugString` or `conf.getAll` to have the `spark.*` system properties loaded printed out.

[source, scala]
----
scala> conf.getAll
res0: Array[(String, String)] = Array((spark.app.name,Spark shell), (spark.jars,""), (spark.master,local[*]), (spark.submit.deployMode,client))

scala> conf.toDebugString
res1: String =
spark.app.name=Spark shell
spark.jars=
spark.master=local[*]
spark.submit.deployMode=client

scala> println(conf.toDebugString)
spark.app.name=Spark shell
spark.jars=
spark.master=local[*]
spark.submit.deployMode=client
----

== [[getAppId]] Unique Identifier of Spark Application -- getAppId Method

[source, scala]
----
getAppId: String
----

getAppId returns the value of configuration-properties.md#spark.app.id[spark.app.id] configuration property or throws a `NoSuchElementException` if not set.

getAppId is used when:

* NettyBlockTransferService is requested to storage:NettyBlockTransferService.md#init[init] (and creates a storage:NettyBlockRpcServer.md#creating-instance[NettyBlockRpcServer] as well as storage:NettyBlockTransferService.md#appId[saves the identifier for later use]).

* Executor executor:Executor.md#creating-instance[is created] (in non-local mode and storage:BlockManager.md#initialize[requests `BlockManager` to initialize]).

== [[getAvroSchema]] getAvroSchema Method

[source, scala]
----
getAvroSchema: Map[Long, String]
----

getAvroSchema takes all *avro.schema*-prefixed configuration properties from <<getAll, getAll>> and...FIXME

getAvroSchema is used when KryoSerializer is created (and initializes avroSchemas).
