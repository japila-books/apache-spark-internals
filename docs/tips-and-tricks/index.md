# Spark's Tips and Tricks

## Print Launch Command of Spark Scripts { #SPARK_PRINT_LAUNCH_COMMAND }

`SPARK_PRINT_LAUNCH_COMMAND` environment variable controls whether or not the Spark launch command is printed out to the standard error output.

All the Spark shell scripts use `org.apache.spark.launcher.Main` class internally that checks `SPARK_PRINT_LAUNCH_COMMAND` and when set (to any value) will print out the entire command line to launch it.

```text
$ SPARK_PRINT_LAUNCH_COMMAND=1 ./bin/spark-shell
Spark Command: /Library/Java/JavaVirtualMachines/Current/Contents/Home/bin/java -cp /Users/jacek/dev/oss/spark/conf/:/Users/jacek/dev/oss/spark/assembly/target/scala-2.11/spark-assembly-1.6.0-SNAPSHOT-hadoop2.7.1.jar:/Users/jacek/dev/oss/spark/lib_managed/jars/datanucleus-api-jdo-3.2.6.jar:/Users/jacek/dev/oss/spark/lib_managed/jars/datanucleus-core-3.2.10.jar:/Users/jacek/dev/oss/spark/lib_managed/jars/datanucleus-rdbms-3.2.9.jar -Dscala.usejavacp=true -Xms1g -Xmx1g org.apache.spark.deploy.SparkSubmit --master spark://localhost:7077 --class org.apache.spark.repl.Main --name Spark shell spark-shell
========================================
```

## Show Spark version in Spark shell

In spark-shell, use `sc.version` or `org.apache.spark.SPARK_VERSION` to know the Spark version:

```text
scala> sc.version
res0: String = 1.6.0-SNAPSHOT

scala> org.apache.spark.SPARK_VERSION
res1: String = 1.6.0-SNAPSHOT
```

## Resolving local host name

When you face networking issues when Spark can't resolve your local hostname or IP address, use the preferred `SPARK_LOCAL_HOSTNAME` environment variable as the custom host name or `SPARK_LOCAL_IP` as the custom IP that is going to be later resolved to a hostname.

Spark checks them out before using [java.net.InetAddress.getLocalHost()](http://docs.oracle.com/javase/8/docs/api/java/net/InetAddress.html#getLocalHost--) (consult [org.apache.spark.util.Utils.findLocalInetAddress()](https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/util/Utils.scala#L759) method).

You may see the following WARN messages in the logs when Spark finished the resolving process:

```text
Your hostname, [hostname] resolves to a loopback address: [host-address]; using...
Set SPARK_LOCAL_IP if you need to bind to another address
```

## Starting standalone Master and workers on Windows 7

Windows 7 users can use [spark-class](../tools/spark-class.md) to start Spark Standalone as there are no launch scripts for the Windows platform.

```text
./bin/spark-class org.apache.spark.deploy.master.Master -h localhost
```

```text
./bin/spark-class org.apache.spark.deploy.worker.Worker spark://localhost:7077
```
