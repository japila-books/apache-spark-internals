== WordCount using Spark shell

It is like any introductory big data example should somehow demonstrate how to count words in distributed fashion.

In the following example you're going to count the words in `README.md` file that sits in your Spark distribution and save the result under `README.count` directory.

You're going to use spark-shell.md[the Spark shell] for the example. Execute `spark-shell`.

[source,scala]
----
val lines = sc.textFile("README.md")               // <1>

val words = lines.flatMap(_.split("\\s+"))         // <2>

val wc = words.map(w => (w, 1)).reduceByKey(_ + _) // <3>

wc.saveAsTextFile("README.count")                  // <4>
----
<1> Read the text file - refer to spark-io.md[Using Input and Output (I/O)].
<2> Split each line into words and flatten the result.
<3> Map each word into a pair and count them by word (key).
<4> Save the result into text files - one per partition.

After you have executed the example, see the contents of the `README.count` directory:

```
$ ls -lt README.count
total 16
-rw-r--r--  1 jacek  staff     0  9 paź 13:36 _SUCCESS
-rw-r--r--  1 jacek  staff  1963  9 paź 13:36 part-00000
-rw-r--r--  1 jacek  staff  1663  9 paź 13:36 part-00001
```

The files `part-0000x` contain the pairs of word and the count.

```
$ cat README.count/part-00000
(package,1)
(this,1)
(Version"](http://spark.apache.org/docs/latest/building-spark.html#specifying-the-hadoop-version),1)
(Because,1)
(Python,2)
(cluster.,1)
(its,1)
([run,1)
...
```

=== Further (self-)development

Please read the questions and give answers first before looking at the link given.

1. Why are there two files under the directory?
2. How could you have only one?
3. How to `filter` out words by name?
4. How to `count` words?

Please refer to the chapter spark-rdd-partitions.md[Partitions] to find some of the answers.
