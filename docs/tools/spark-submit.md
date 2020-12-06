# spark-submit shell script

`spark-submit` shell script allows you to manage your Spark applications.

`spark-submit` is a command-line frontend to [SparkSubmit](SparkSubmit.md).

## <span id="options"> Command-Line Options

### <span id="archives"> archives

Command-Line Option: `--archives`
Internal Property: `archives`

### <span id="deploy-mode"> deploy-mode

Deploy mode

Command-Line Option: `--deploy-mode`
Spark Property: `spark.submit.deployMode`
Environment Variable: `DEPLOY_MODE`
Internal Property: `deployMode`

### <span id="driver-class-path"> driver-class-path

```text
--driver-class-path
```

Extra class path entries (e.g. jars and directories) to pass to a driver's JVM.

`--driver-class-path` command-line option sets the extra class path entries (e.g. jars and directories) that should be added to a driver's JVM.

!!! tip
    Use `--driver-class-path` in `client` deploy mode (not [SparkConf](../SparkConf.md)) to ensure that the CLASSPATH is set up with the entries.
    
    `client` deploy mode uses the same JVM for the driver as `spark-submit`'s.

Internal Property: `driverExtraClassPath`

Spark Property: [spark.driver.extraClassPath](../driver.md#spark_driver_extraClassPath)

!!! note
    Command-line options (e.g. `--driver-class-path`) have higher precedence than their corresponding Spark settings in a Spark properties file (e.g. `spark.driver.extraClassPath`). You can therefore control the final settings by overriding Spark settings on command line using the command-line options.

### <span id="driver-cores"> driver-cores

```text
--driver-cores NUM
```

`--driver-cores` command-line option sets the number of cores to `NUM` for the [driver](../driver.md) in the [cluster deploy mode](../spark-deploy-mode.md#cluster).

Spark Property: [spark.driver.cores](../driver.md#spark_driver_cores)

!!! note
    Only available for `cluster` deploy mode (when the driver is executed outside `spark-submit`).

Internal Property: `driverCores`

### <span id="properties-file"> properties-file

```text
--properties-file [FILE]
```

`--properties-file` command-line option sets the path to a file `FILE` from which Spark loads extra [Spark properties](../spark-properties.md).

!!! note
    Spark uses [conf/spark-defaults.conf](../spark-properties.md#spark-defaults-conf) by default.

### <span id="queue"> queue

```text
--queue QUEUE_NAME
```

YARN resource queue

Spark Property: `spark.yarn.queue`
Internal Property: `queue`

### <span id="version"> version

Command-Line Option: `--version`

```text
$ ./bin/spark-submit --version
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.1.0-SNAPSHOT
      /_/

Branch master
Compiled by user jacek on 2016-09-30T07:08:39Z
Revision 1fad5596885aab8b32d2307c0edecbae50d5bd7a
Url https://github.com/apache/spark.git
Type --help for more information.
```

| `--conf` | | | | `sparkProperties`
| `--driver-java-options` | `spark.driver.extraJavaOptions` | | The driver's JVM options | `driverExtraJavaOptions`
| `--driver-library-path` | `spark.driver.extraLibraryPath` | | The driver's native library path | `driverExtraLibraryPath`
| [[driver-memory]] `--driver-memory` | [[spark_driver_memory]] `spark.driver.memory` | `SPARK_DRIVER_MEMORY` | The driver's memory | `driverMemory`
| `--exclude-packages` | `spark.jars.excludes` | | | `packagesExclusions`
| `--executor-cores` | `spark.executor.cores` | `SPARK_EXECUTOR_CORES` | The number of executor CPU cores | `executorCores`
| [[executor-memory]] `--executor-memory` | [[spark.executor.memory]] `spark.executor.memory` | `SPARK_EXECUTOR_MEMORY` | An executor's memory | `executorMemory`
| `--files` | `spark.files` | | | `files`
| `ivyRepoPath` | `spark.jars.ivy` | | |
| `--jars` | `spark.jars` | | | `jars`
| `--keytab` | `spark.yarn.keytab` | | | `keytab`
| `--kill` | | | `submissionToKill` and `action` set to `KILL` |
| `--master` | `spark.master` | `MASTER` | Master URL. Defaults to `local[*]` | `master`
| `--class` | | | | `mainClass`
| `--name` | `spark.app.name` | `SPARK_YARN_APP_NAME` (YARN only) | Uses `mainClass` or the directory off `primaryResource` when no other ways set it | `name`
| `--num-executors` | executor:Executor.md#spark.executor.instances[spark.executor.instances] | | | `numExecutors`
| [[packages]] `--packages` | `spark.jars.packages` | | | `packages`
| `--principal` | `spark.yarn.principal` | | | `principal`
| `--properties-file` | `spark.yarn.principal` | | | `propertiesFile`
| `--proxy-user` | | | | `proxyUser`
| `--py-files` | | | | `pyFiles`
| `--repositories` | | | | `repositories`
| `--status` | | | `submissionToRequestStatusFor` and `action` set to `REQUEST_STATUS` |
| `--supervise` | | | | `supervise`
| `--total-executor-cores` | `spark.cores.max` | | | `totalExecutorCores`
| `--verbose` | | | | `verbose`
| `--help` | | | `printUsageAndExit(0)` |

## <span id="SPARK_PRINT_LAUNCH_COMMAND"> SPARK_PRINT_LAUNCH_COMMAND

[SPARK_PRINT_LAUNCH_COMMAND](../spark-tips-and-tricks.md#SPARK_PRINT_LAUNCH_COMMAND) environment variable allows to have the complete Spark command printed out to the standard output.

```text
$ SPARK_PRINT_LAUNCH_COMMAND=1 ./bin/spark-shell
Spark Command: /Library/Ja...
```

## Avoid scala.App

Avoid using `scala.App` trait for a Spark application's main class in Scala as reported in [SPARK-4170 Closure problems when running Scala app that "extends App"](https://issues.apache.org/jira/browse/SPARK-4170).

## Command-line Options

Execute `spark-submit --help` to know about the command-line options supported.

```
➜  spark git:(master) ✗ ./bin/spark-submit --help
Usage: spark-submit [options] <app jar | python file> [app arguments]
Usage: spark-submit --kill [submission ID] --master [spark://...]
Usage: spark-submit --status [submission ID] --master [spark://...]
Usage: spark-submit run-example [options] example-class [example args]

Options:
  --master MASTER_URL         spark://host:port, mesos://host:port, yarn, or local.
  --deploy-mode DEPLOY_MODE   Whether to launch the driver program locally ("client") or
                              on one of the worker machines inside the cluster ("cluster")
                              (Default: client).
  --class CLASS_NAME          Your application's main class (for Java / Scala apps).
  --name NAME                 A name of your application.
  --jars JARS                 Comma-separated list of local jars to include on the driver
                              and executor classpaths.
  --packages                  Comma-separated list of maven coordinates of jars to include
                              on the driver and executor classpaths. Will search the local
                              maven repo, then maven central and any additional remote
                              repositories given by --repositories. The format for the
                              coordinates should be groupId:artifactId:version.
  --exclude-packages          Comma-separated list of groupId:artifactId, to exclude while
                              resolving the dependencies provided in --packages to avoid
                              dependency conflicts.
  --repositories              Comma-separated list of additional remote repositories to
                              search for the maven coordinates given with --packages.
  --py-files PY_FILES         Comma-separated list of .zip, .egg, or .py files to place
                              on the PYTHONPATH for Python apps.
  --files FILES               Comma-separated list of files to be placed in the working
                              directory of each executor.

  --conf PROP=VALUE           Arbitrary Spark configuration property.
  --properties-file FILE      Path to a file from which to load extra properties. If not
                              specified, this will look for conf/spark-defaults.conf.

  --driver-memory MEM         Memory for driver (e.g. 1000M, 2G) (Default: 1024M).
  --driver-java-options       Extra Java options to pass to the driver.
  --driver-library-path       Extra library path entries to pass to the driver.
  --driver-class-path         Extra class path entries to pass to the driver. Note that
                              jars added with --jars are automatically included in the
                              classpath.

  --executor-memory MEM       Memory per executor (e.g. 1000M, 2G) (Default: 1G).

  --proxy-user NAME           User to impersonate when submitting the application.
                              This argument does not work with --principal / --keytab.

  --help, -h                  Show this help message and exit.
  --verbose, -v               Print additional debug output.
  --version,                  Print the version of current Spark.

 Spark standalone with cluster deploy mode only:
  --driver-cores NUM          Cores for driver (Default: 1).

 Spark standalone or Mesos with cluster deploy mode only:
  --supervise                 If given, restarts the driver on failure.
  --kill SUBMISSION_ID        If given, kills the driver specified.
  --status SUBMISSION_ID      If given, requests the status of the driver specified.

 Spark standalone and Mesos only:
  --total-executor-cores NUM  Total cores for all executors.

 Spark standalone and YARN only:
  --executor-cores NUM        Number of cores per executor. (Default: 1 in YARN mode,
                              or all available cores on the worker in standalone mode)

 YARN-only:
  --driver-cores NUM          Number of cores used by the driver, only in cluster mode
                              (Default: 1).
  --queue QUEUE_NAME          The YARN queue to submit to (Default: "default").
  --num-executors NUM         Number of executors to launch (Default: 2).
  --archives ARCHIVES         Comma separated list of archives to be extracted into the
                              working directory of each executor.
  --principal PRINCIPAL       Principal to be used to login to KDC, while running on
                              secure HDFS.
  --keytab KEYTAB             The full path to the file that contains the keytab for the
                              principal specified above. This keytab will be copied to
                              the node running the Application Master via the Secure
                              Distributed Cache, for renewing the login tickets and the
                              delegation tokens periodically.
```

* `--class`
* `--conf` or `-c`
* `--deploy-mode` (see <<deploy-mode, Deploy Mode>>)
* `--driver-class-path` (see <<driver-class-path, `--driver-class-path` command-line option>>)
* `--driver-cores`  (see <<driver-cores, Driver Cores in Cluster Deploy Mode>>)
* `--driver-java-options`
* `--driver-library-path`
* `--driver-memory`
* `--executor-memory`
* `--files`
* `--jars`
* `--kill` for spark-standalone.md[Standalone cluster mode] only
* `--master`
* `--name`
* `--packages`
* `--exclude-packages`
* `--properties-file` (see <<properties-file, Custom Spark Properties File>>)
* `--proxy-user`
* `--py-files`
* `--repositories`
* `--status` for spark-standalone.md[Standalone cluster mode] only
* `--total-executor-cores`

List of switches, i.e. command-line options that do not take parameters:

* `--help` or `-h`
* `--supervise` for spark-standalone.md[Standalone cluster mode] only
* `--usage-error`
* `--verbose` or `-v` (see <<verbose-mode, Verbose Mode>>)
* `--version` (see <<version, Version>>)

YARN-only options:

* `--archives`
* `--executor-cores`
* `--keytab`
* `--num-executors`
* `--principal`
* `--queue` (see <<queue, Specifying YARN Resource Queue (--queue switch)>>)

## Environment Variables

The following is the list of environment variables that are considered when command-line options are not specified:

* `MASTER` for `--master`
* `SPARK_DRIVER_MEMORY` for `--driver-memory`
* `SPARK_EXECUTOR_MEMORY` (see SparkContext.md#environment-variables[Environment Variables] in the SparkContext document)
* `SPARK_EXECUTOR_CORES`
* `DEPLOY_MODE`
* `SPARK_YARN_APP_NAME`
* `_SPARK_CMD_USAGE`

## External packages and custom repositories

The `spark-submit` utility supports specifying external packages using Maven coordinates using `--packages` and custom repositories using `--repositories`.

```
./bin/spark-submit \
  --packages my:awesome:package \
  --repositories s3n://$aws_ak:$aws_sak@bucket/path/to/repo
```
