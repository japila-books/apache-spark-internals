# SparkConf

`SparkConf` is `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).

## Creating Instance

`SparkConf` takes the following to be created:

* [loadDefaults](#loadDefaults) flag

### <span id="loadDefaults"> loadDefaults Flag

`SparkConf` can be given `loadDefaults` flag when [created](#creating-instance).

Default: `true`

When `true`, `SparkConf` [loads spark properties](#loadFromSystemProperties) (with `silent` flag disabled) when [created](#creating-instance).

## <span id="getAllWithPrefix"> getAllWithPrefix

```scala
getAllWithPrefix(
  prefix: String): Array[(String, String)]
```

`getAllWithPrefix` collects the keys with the given `prefix` in [getAll](#getAll).

In the end, `getAllWithPrefix` removes the given `prefix` from the keys.

---

`getAllWithPrefix` is used when:

* `SparkConf` is requested to [getExecutorEnv](#getExecutorEnv) (`spark.executorEnv.` prefix), [fillMissingMagicCommitterConfsIfNeeded](#fillMissingMagicCommitterConfsIfNeeded) (`spark.hadoop.fs.s3a.bucket.` prefix)
* `ExecutorPluginContainer` is requested for the [executorPlugins](plugins/ExecutorPluginContainer.md#executorPlugins) (`spark.plugins.internal.conf.` prefix)
* `ResourceUtils` is requested to [parseResourceRequest](stage-level-scheduling/ResourceUtils.md#parseResourceRequest), [listResourceIds](stage-level-scheduling/ResourceUtils.md#listResourceIds), [addTaskResourceRequests](stage-level-scheduling/ResourceUtils.md#addTaskResourceRequests), [parseResourceRequirements](stage-level-scheduling/ResourceUtils.md#parseResourceRequirements)
* `SortShuffleManager` is requested to [loadShuffleExecutorComponents](shuffle/SortShuffleManager.md#loadShuffleExecutorComponents) (`spark.shuffle.plugin.__config__.` prefix)
* `ServerInfo` is requested to `addFilters`

## <span id="loadFromSystemProperties"> Loading Spark Properties

```scala
loadFromSystemProperties(
  silent: Boolean): SparkConf
```

`loadFromSystemProperties` [records](#set) all the `spark.`-prefixed system properties in this `SparkConf`.

!!! tip "Silently loading system properties"

    Loading system properties silently is possible using the following:

    ```scala
    new SparkConf(loadDefaults = false).loadFromSystemProperties(silent = true)
    ```

---

`loadFromSystemProperties` is used when:

* `SparkConf` is [created](#creating-instance) (with [loadDefaults](#loadDefaults) enabled)
* `SparkHadoopUtil` is created

## <span id="spark.executorEnv"> Executor Settings

`SparkConf` uses `spark.executorEnv.` prefix for executor settings.

### <span id="getExecutorEnv"> getExecutorEnv

```scala
getExecutorEnv: Seq[(String, String)]
```

`getExecutorEnv` [gets all the settings](#getAllWithPrefix) with [spark.executorEnv.](#spark.executorEnv) prefix.

---

`getExecutorEnv` is used when:

* `SparkContext` is [created](SparkContext.md) (and requested for [executorEnvs](SparkContext.md#executorEnvs))

### <span id="setExecutorEnv"> setExecutorEnv

```scala
setExecutorEnv(
  variables: Array[(String, String)]): SparkConf
setExecutorEnv(
  variables: Seq[(String, String)]): SparkConf
setExecutorEnv(
  variable: String, value: String): SparkConf
```

`setExecutorEnv` [sets](#set) the given (key-value) variables with the keys with [spark.executorEnv.](#spark.executorEnv) prefix added.

---

`setExecutorEnv` is used when:

* `SparkContext` is requested to [updatedConf](SparkContext.md#updatedConf)

## Logging

Enable `ALL` logging level for `org.apache.spark.SparkConf` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.SparkConf=ALL
```

Refer to [Logging](spark-logging.md).

<!---
## Review Me

Every user program starts with creating an instance of `SparkConf` that holds the `master URL` to connect to (`spark.master`), the name for your Spark application (that is later displayed in webui:index.md[web UI] and becomes `spark.app.name`) and other Spark properties required for proper runs. The instance of `SparkConf` can be used to create SparkContext.md[SparkContext].

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

== Setting up Spark Properties

There are the following places where a Spark application looks for Spark properties (in the order of importance from the least important to the most important):

* `conf/spark-defaults.conf` - the configuration file with the default Spark properties. Read spark-properties.md#spark-defaults-conf[spark-defaults.conf].
* `--conf` or `-c` - the command-line option used by tools:spark-submit/index.md[spark-submit] (and other shell scripts that use `spark-submit` or `spark-class` under the covers, e.g. `spark-shell`)
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
-->
