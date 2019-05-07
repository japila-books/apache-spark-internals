== Exercise: Spark's Hello World using Spark shell and Scala

Run Spark shell and count the number of words in a file using MapReduce pattern.

* Use `sc.textFile` to read the file into memory
* Use `RDD.flatMap` for a mapper step
* Use `reduceByKey` for a reducer step
