---
title: Java 25
---
# Build and Run Spark on Java 25

Among the [Highlights](https://spark.apache.org/releases/spark-release-4-2-0.html#highlights) of Apache Spark 4.2.0 was [[SPARK-51167] Build and run Spark on Java 25]({{ spark.jira }}/SPARK-51167).

## Build It Yourself

This procedure is based on [.github/workflows/build_maven_java25.yml]({{ spark.github }}/.github/workflows/build_maven_java25.yml).

```console
$ java --version
openjdk 25.0.3 2026-04-21 LTS
OpenJDK Runtime Environment Zulu25.34+17-CA (build 25.0.3+9-LTS)
OpenJDK 64-Bit Server VM Zulu25.34+17-CA (build 25.0.3+9-LTS, mixed mode, sharing)
```

Optionally, wipe out local build directories.

```shell
rm -rf ~/.ivy2/local ~/.ivy2/cache
```

Check out [v4.2.0]({{ spark.github }}) tag.

```shell
gswc v4.2.0 v4.2.0
```

```shell
./build/mvn \
    --no-transfer-progress \
    -DskipTests \
    -Phadoop-cloud,hive,hive-thriftserver,kubernetes,volcano,yarn,jvm-profiler \
    -Djava.version=25 \
    -Dmaven.javadoc.skip=true \
    -Dmaven.scaladoc.skip=true \
    -Dmaven.source.skip \
    -Dcyclonedx.skip=true \
    clean install
```

You should see a similar summary at the end of the build.

```text
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  08:49 min
[INFO] Finished at: 2026-07-18T19:26:06+02:00
[INFO] ------------------------------------------------------------------------
```

Spark 4.2.0 on Java 25 is ready for prime time! 🥳

```console
$ ./bin/spark-shell --version
WARNING: Using incubator modules: jdk.incubator.vector
WARNING: package sun.security.action not in java.base
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 4.2.0
      /_/

Using Scala version 2.13.18, OpenJDK 64-Bit Server VM, 25.0.3
Branch heads/v4.2.0
Compiled by user jacek on 2026-07-18T17:17:29Z
Revision 32f7299601108917fb01920a54e084595b7b3bf8
Url https://github.com/apache/spark.git
Type --help for more information.
```
