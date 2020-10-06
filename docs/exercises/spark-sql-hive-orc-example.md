== Using Spark SQL to update data in Hive using ORC files

The example has showed up on Spark's users mailing list.

[CAUTION]
====
* FIXME Offer a complete working solution in Scala
* FIXME Load ORC files into dataframe
** `val df = hiveContext.read.format("orc").load(to/path)`
====

Solution was to use Hive in ORC format with partitions:

* A table in Hive stored as an ORC file (using partitioning)
* Using `SQLContext.sql` to insert data into the table
* Using `SQLContext.sql` to periodically run `ALTER TABLE...CONCATENATE` to merge your many small files into larger files optimized for your HDFS block size
** Since the `CONCATENATE` command operates on files in place it is transparent to any downstream processing
* Hive solution is just to concatenate the files
** it does not alter or change records.
** it's possible to update data in Hive using ORC format
** With transactional tables in Hive together with insert, update, delete, it does the "concatenate " for you automatically in regularly intervals. Currently this works only with tables in orc.format (stored as orc)
** Alternatively, use Hbase with Phoenix as the SQL layer on top
** Hive was originally not designed for updates,  because it was.purely warehouse focused, the most recent one can do updates, deletes etc in a transactional way.

Criteria:

* spark-streaming/spark-streaming.md[Spark Streaming] jobs are receiving a lot of small events (avg 10kb)
* Events are stored to HDFS, e.g. for Pig jobs
* There are a lot of small files in HDFS (several millions)
