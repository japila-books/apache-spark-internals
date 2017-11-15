== Debugging Spark

=== Using spark-shell and IntelliJ IDEA

Start `spark-shell` with `SPARK_SUBMIT_OPTS` environment variable that configures the JVM's JDWP.

```
SPARK_SUBMIT_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" ./bin/spark-shell
```

Attach IntelliJ IDEA to the JVM process using *Run > Attach to Local Process* menu.

=== Using sbt

Use `sbt -jvm-debug 5005`, connect to the remote JVM at the port `5005` using IntelliJ IDEA, place breakpoints on the desired lines of the source code of Spark.

```
➜  sparkme-app  sbt -jvm-debug 5005
Listening for transport dt_socket at address: 5005
...
```

Run Spark context and the breakpoints get triggered.

```
scala> val sc = new SparkContext(conf)
15/11/14 22:58:46 INFO SparkContext: Running Spark version 1.6.0-SNAPSHOT
```

TIP: Read https://www.jetbrains.com/idea/help/debugging-2.html[Debugging] chapter in IntelliJ IDEA 15.0 Help.
