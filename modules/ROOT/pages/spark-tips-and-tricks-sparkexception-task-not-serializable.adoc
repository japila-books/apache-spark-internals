== org.apache.spark.SparkException: Task not serializable

When you run into `org.apache.spark.SparkException: Task not serializable` exception, it means that you use a reference to an instance of a non-serializable class inside a transformation. See the following example:

```
➜  spark git:(master) ✗ ./bin/spark-shell
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 1.6.0-SNAPSHOT
      /_/

Using Scala version 2.11.7 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_66)
Type in expressions to have them evaluated.
Type :help for more information.

scala> class NotSerializable(val num: Int)
defined class NotSerializable

scala> val notSerializable = new NotSerializable(10)
notSerializable: NotSerializable = NotSerializable@2700f556

scala> sc.parallelize(0 to 10).map(_ => notSerializable.num).count
org.apache.spark.SparkException: Task not serializable
  at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:304)
  at org.apache.spark.util.ClosureCleaner$.org$apache$spark$util$ClosureCleaner$$clean(ClosureCleaner.scala:294)
  at org.apache.spark.util.ClosureCleaner$.clean(ClosureCleaner.scala:122)
  at org.apache.spark.SparkContext.clean(SparkContext.scala:2055)
  at org.apache.spark.rdd.RDD$$anonfun$map$1.apply(RDD.scala:318)
  at org.apache.spark.rdd.RDD$$anonfun$map$1.apply(RDD.scala:317)
  at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:150)
  at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:111)
  at org.apache.spark.rdd.RDD.withScope(RDD.scala:310)
  at org.apache.spark.rdd.RDD.map(RDD.scala:317)
  ... 48 elided
Caused by: java.io.NotSerializableException: NotSerializable
Serialization stack:
	- object not serializable (class: NotSerializable, value: NotSerializable@2700f556)
	- field (class: $iw, name: notSerializable, type: class NotSerializable)
	- object (class $iw, $iw@10e542f3)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@729feae8)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@5fc3b20b)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@36dab184)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@5eb974)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@79c514e4)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@5aeaee3)
	- field (class: $iw, name: $iw, type: class $iw)
	- object (class $iw, $iw@2be9425f)
	- field (class: $line18.$read, name: $iw, type: class $iw)
	- object (class $line18.$read, $line18.$read@6311640d)
	- field (class: $iw, name: $line18$read, type: class $line18.$read)
	- object (class $iw, $iw@c9cd06e)
	- field (class: $iw, name: $outer, type: class $iw)
	- object (class $iw, $iw@6565691a)
	- field (class: $anonfun$1, name: $outer, type: class $iw)
	- object (class $anonfun$1, <function1>)
  at org.apache.spark.serializer.SerializationDebugger$.improveException(SerializationDebugger.scala:40)
  at org.apache.spark.serializer.JavaSerializationStream.writeObject(JavaSerializer.scala:47)
  at org.apache.spark.serializer.JavaSerializerInstance.serialize(JavaSerializer.scala:101)
  at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:301)
  ... 57 more
```

=== Further reading

* https://databricks.gitbooks.io/databricks-spark-knowledge-base/content/troubleshooting/javaionotserializableexception.html[Job aborted due to stage failure: Task not serializable]
* https://issues.apache.org/jira/browse/SPARK-5307[Add utility to help with NotSerializableException debugging]
* http://stackoverflow.com/q/22592811/1305344[Task not serializable: java.io.NotSerializableException when calling function outside closure only on classes not objects]
