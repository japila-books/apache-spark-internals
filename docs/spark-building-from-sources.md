== Building Apache Spark from Sources

You can download pre-packaged versions of Apache Spark from http://spark.apache.org/downloads.html[the project's web site]. The packages are built for a different Hadoop versions for Scala 2.11.

NOTE: Since https://github.com/apache/spark/commit/289373b28cd2546165187de2e6a9185a1257b1e7[[SPARK-6363\][BUILD\] Make Scala 2.11 the default Scala version] the default version of Scala in Apache Spark is *2.11*.

The build process for Scala 2.11 takes less than 15 minutes (on a decent machine like my shiny MacBook Pro with 8 cores and 16 GB RAM) and is so simple that it's unlikely to refuse the urge to do it yourself.

You can use <<sbt, sbt>> or <<maven, Maven>> as the build command.

=== [[sbt]] Using sbt as the build tool

The build command with sbt as the build tool is as follows:

```
./build/sbt -Phadoop-2.7,yarn,mesos,hive,hive-thriftserver -DskipTests clean assembly
```

Using Java 8 to build Spark using sbt takes ca 10 minutes.

```
➜  spark git:(master) ✗ ./build/sbt -Phadoop-2.7,yarn,mesos,hive,hive-thriftserver -DskipTests clean assembly
...
[success] Total time: 496 s, completed Dec 7, 2015 8:24:41 PM
```

=== [[profiles]] Build Profiles

CAUTION: FIXME Describe yarn profile and others

==== [[hive-thriftserver]] `hive-thriftserver` Maven profile for Spark Thrift Server

CAUTION: FIXME

TIP: Read spark-sql-thrift-server.md[Thrift JDBC/ODBC Server -- Spark Thrift Server (STS)].

=== [[maven]] Using Apache Maven as the build tool

The build command with Apache Maven is as follows:

```
$ ./build/mvn -Phadoop-2.7,yarn,mesos,hive,hive-thriftserver -DskipTests clean install
```

After a couple of minutes your freshly baked distro is ready to fly!

I'm using Oracle Java 8 to build Spark.

```
➜  spark git:(master) ✗ java -version
java version "1.8.0_102"
Java(TM) SE Runtime Environment (build 1.8.0_102-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.102-b14, mixed mode)

➜  spark git:(master) ✗ ./build/mvn -Phadoop-2.7,yarn,mesos,hive,hive-thriftserver -DskipTests clean install
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
Using `mvn` from path: /usr/local/bin/mvn
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO]
[INFO] Spark Project Parent POM
[INFO] Spark Project Tags
[INFO] Spark Project Sketch
[INFO] Spark Project Networking
[INFO] Spark Project Shuffle Streaming Service
[INFO] Spark Project Unsafe
[INFO] Spark Project Launcher
[INFO] Spark Project Core
[INFO] Spark Project GraphX
[INFO] Spark Project Streaming
[INFO] Spark Project Catalyst
[INFO] Spark Project SQL
[INFO] Spark Project ML Local Library
[INFO] Spark Project ML Library
[INFO] Spark Project Tools
[INFO] Spark Project Hive
[INFO] Spark Project REPL
[INFO] Spark Project YARN Shuffle Service
[INFO] Spark Project YARN
[INFO] Spark Project Hive Thrift Server
[INFO] Spark Project Assembly
[INFO] Spark Project External Flume Sink
[INFO] Spark Project External Flume
[INFO] Spark Project External Flume Assembly
[INFO] Spark Integration for Kafka 0.8
[INFO] Spark Project Examples
[INFO] Spark Project External Kafka Assembly
[INFO] Spark Integration for Kafka 0.10
[INFO] Spark Integration for Kafka 0.10 Assembly
[INFO] Spark Project Java 8 Tests
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building Spark Project Parent POM 2.0.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO]
[INFO] Spark Project Parent POM ........................... SUCCESS [  4.186 s]
[INFO] Spark Project Tags ................................. SUCCESS [  4.893 s]
[INFO] Spark Project Sketch ............................... SUCCESS [  5.066 s]
[INFO] Spark Project Networking ........................... SUCCESS [ 11.108 s]
[INFO] Spark Project Shuffle Streaming Service ............ SUCCESS [  7.051 s]
[INFO] Spark Project Unsafe ............................... SUCCESS [  7.650 s]
[INFO] Spark Project Launcher ............................. SUCCESS [  9.905 s]
[INFO] Spark Project Core ................................. SUCCESS [02:09 min]
[INFO] Spark Project GraphX ............................... SUCCESS [ 19.317 s]
[INFO] Spark Project Streaming ............................ SUCCESS [ 42.077 s]
[INFO] Spark Project Catalyst ............................. SUCCESS [01:32 min]
[INFO] Spark Project SQL .................................. SUCCESS [01:47 min]
[INFO] Spark Project ML Local Library ..................... SUCCESS [ 10.049 s]
[INFO] Spark Project ML Library ........................... SUCCESS [01:36 min]
[INFO] Spark Project Tools ................................ SUCCESS [  3.520 s]
[INFO] Spark Project Hive ................................. SUCCESS [ 52.528 s]
[INFO] Spark Project REPL ................................. SUCCESS [  7.243 s]
[INFO] Spark Project YARN Shuffle Service ................. SUCCESS [  7.898 s]
[INFO] Spark Project YARN ................................. SUCCESS [ 15.380 s]
[INFO] Spark Project Hive Thrift Server ................... SUCCESS [ 24.876 s]
[INFO] Spark Project Assembly ............................. SUCCESS [  2.971 s]
[INFO] Spark Project External Flume Sink .................. SUCCESS [  7.377 s]
[INFO] Spark Project External Flume ....................... SUCCESS [ 10.752 s]
[INFO] Spark Project External Flume Assembly .............. SUCCESS [  1.695 s]
[INFO] Spark Integration for Kafka 0.8 .................... SUCCESS [ 13.013 s]
[INFO] Spark Project Examples ............................. SUCCESS [ 31.728 s]
[INFO] Spark Project External Kafka Assembly .............. SUCCESS [  3.472 s]
[INFO] Spark Integration for Kafka 0.10 ................... SUCCESS [ 12.297 s]
[INFO] Spark Integration for Kafka 0.10 Assembly .......... SUCCESS [  3.789 s]
[INFO] Spark Project Java 8 Tests ......................... SUCCESS [  4.267 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 12:29 min
[INFO] Finished at: 2016-07-07T22:29:56+02:00
[INFO] Final Memory: 110M/913M
[INFO] ------------------------------------------------------------------------
```

Please note the messages that say the version of Spark (_Building Spark Project Parent POM 2.0.0-SNAPSHOT_), Scala version (_maven-clean-plugin:2.6.1:clean (default-clean) @ spark-parent_2.11_) and the Spark modules built.

The above command gives you the latest version of *Apache Spark 2.0.0-SNAPSHOT* built for *Scala 2.11.8* (see https://github.com/apache/spark/blob/master/pom.xml#L2640-L2674[the configuration of `scala-2.11` profile]).

TIP: You can also know the version of Spark using `./bin/spark-shell --version`.

=== [[make-distribution]] Making Distribution

`./make-distribution.sh` is the shell script to make a distribution. It uses the same profiles as for sbt and Maven.

Use `--tgz` option to have a tar gz version of the Spark distribution.

```
➜  spark git:(master) ✗ ./make-distribution.sh --tgz -Phadoop-2.7,yarn,mesos,hive,hive-thriftserver -DskipTests
```

Once finished, you will have the distribution in the current directory, i.e. `spark-2.0.0-SNAPSHOT-bin-2.7.2.tgz`.
