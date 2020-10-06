== Working with Datasets from JDBC Data Sources (and PostgreSQL)

Start `spark-shell` with the JDBC driver for the database you want to use. In our case, it is PostgreSQL JDBC Driver.

NOTE: Download the jar for PostgreSQL JDBC Driver 42.1.1 directly from the http://central.maven.org/maven2/org/postgresql/postgresql/42.1.1/postgresql-42.1.1.jar[Maven repository].

[TIP]
====
Execute the command to have the jar downloaded into `~/.ivy2/jars` directory by `spark-shell` itself:

```
./bin/spark-shell --packages org.postgresql:postgresql:42.1.1
```

The entire path to the driver file is then like `/Users/jacek/.ivy2/jars/org.postgresql_postgresql-42.1.1.jar`.

You should see the following while `spark-shell` downloads the driver.

```
Ivy Default Cache set to: /Users/jacek/.ivy2/cache
The jars for the packages stored in: /Users/jacek/.ivy2/jars
:: loading settings :: url = jar:file:/Users/jacek/dev/oss/spark/assembly/target/scala-2.11/jars/ivy-2.4.0.jar!/org/apache/ivy/core/settings/ivysettings.xml
org.postgresql#postgresql added as a dependency
:: resolving dependencies :: org.apache.spark#spark-submit-parent;1.0
	confs: [default]
	found org.postgresql#postgresql;42.1.1 in central
downloading https://repo1.maven.org/maven2/org/postgresql/postgresql/42.1.1/postgresql-42.1.1.jar ...
	[SUCCESSFUL ] org.postgresql#postgresql;42.1.1!postgresql.jar(bundle) (205ms)
:: resolution report :: resolve 1887ms :: artifacts dl 207ms
	:: modules in use:
	org.postgresql#postgresql;42.1.1 from central in [default]
	---------------------------------------------------------------------
	|                  |            modules            ||   artifacts   |
	|       conf       | number| search|dwnlded|evicted|| number|dwnlded|
	---------------------------------------------------------------------
	|      default     |   1   |   1   |   1   |   0   ||   1   |   1   |
	---------------------------------------------------------------------
:: retrieving :: org.apache.spark#spark-submit-parent
	confs: [default]
	1 artifacts copied, 0 already retrieved (695kB/8ms)
```
====

Start `./bin/spark-shell` with spark-submit.md#driver-class-path[--driver-class-path] command line option and the driver jar.

```
SPARK_PRINT_LAUNCH_COMMAND=1 ./bin/spark-shell --driver-class-path /Users/jacek/.ivy2/jars/org.postgresql_postgresql-42.1.1.jar
```

It will give you the proper setup for accessing PostgreSQL using the JDBC driver.

Execute the following to access `projects` table in `sparkdb`.

[source, scala]
----
// that gives an one-partition Dataset
val opts = Map(
  "url" -> "jdbc:postgresql:sparkdb",
  "dbtable" -> "projects")
val df = spark.
  read.
  format("jdbc").
  options(opts).
  load
----

NOTE: Use `user` and `password` options to specify the credentials if needed.

[source, scala]
----
// Note the number of partition (aka numPartitions)
scala> df.explain
== Physical Plan ==
*Scan JDBCRelation(projects) [numPartitions=1] [id#0,name#1,website#2] ReadSchema: struct<id:int,name:string,website:string>

scala> df.show(truncate = false)
+---+------------+-----------------------+
|id |name        |website                |
+---+------------+-----------------------+
|1  |Apache Spark|http://spark.apache.org|
|2  |Apache Hive |http://hive.apache.org |
|3  |Apache Kafka|http://kafka.apache.org|
|4  |Apache Flink|http://flink.apache.org|
+---+------------+-----------------------+

// use jdbc method with predicates to define partitions
import java.util.Properties
val df4parts = spark.
  read.
  jdbc(
    url = "jdbc:postgresql:sparkdb",
    table = "projects",
    predicates = Array("id=1", "id=2", "id=3", "id=4"),
    connectionProperties = new Properties())

// Note the number of partitions (aka numPartitions)
scala> df4parts.explain
== Physical Plan ==
*Scan JDBCRelation(projects) [numPartitions=4] [id#16,name#17,website#18] ReadSchema: struct<id:int,name:string,website:string>

scala> df4parts.show(truncate = false)
+---+------------+-----------------------+
|id |name        |website                |
+---+------------+-----------------------+
|1  |Apache Spark|http://spark.apache.org|
|2  |Apache Hive |http://hive.apache.org |
|3  |Apache Kafka|http://kafka.apache.org|
|4  |Apache Flink|http://flink.apache.org|
+---+------------+-----------------------+
----

=== Troubleshooting

If things can go wrong, they sooner or later go wrong. Here is a list of possible issues and their solutions.

==== java.sql.SQLException: No suitable driver

Ensure that the JDBC driver sits on the CLASSPATH. Use spark-submit.md#driver-class-path[--driver-class-path] as described above (`--packages` or `--jars` do not work).

```
scala> val df = spark.
     |   read.
     |   format("jdbc").
     |   options(opts).
     |   load
java.sql.SQLException: No suitable driver
  at java.sql.DriverManager.getDriver(DriverManager.java:315)
  at org.apache.spark.sql.execution.datasources.jdbc.JDBCOptions$$anonfun$7.apply(JDBCOptions.scala:84)
  at org.apache.spark.sql.execution.datasources.jdbc.JDBCOptions$$anonfun$7.apply(JDBCOptions.scala:84)
  at scala.Option.getOrElse(Option.scala:121)
  at org.apache.spark.sql.execution.datasources.jdbc.JDBCOptions.<init>(JDBCOptions.scala:83)
  at org.apache.spark.sql.execution.datasources.jdbc.JDBCOptions.<init>(JDBCOptions.scala:34)
  at org.apache.spark.sql.execution.datasources.jdbc.JdbcRelationProvider.createRelation(JdbcRelationProvider.scala:32)
  at org.apache.spark.sql.execution.datasources.DataSource.resolveRelation(DataSource.scala:301)
  at org.apache.spark.sql.DataFrameReader.load(DataFrameReader.scala:190)
  at org.apache.spark.sql.DataFrameReader.load(DataFrameReader.scala:158)
  ... 52 elided
```

=== PostgreSQL Setup

NOTE: I'm on Mac OS X so YMMV (aka _Your Mileage May Vary_).

Use the sections to have a properly configured PostgreSQL database.

* <<installation, Installation>>
* <<starting-database-server, Starting Database Server>>
* <<creating-database, Create Database>>
* <<accessing-database, Accessing Database>>
* <<creating-table, Creating Table>>
* <<dropping-database, Dropping Database>>
* <<stopping-database-server, Stopping Database Server>>

==== [[installation]] Installation

Install PostgreSQL as described in...TK

CAUTION: This page serves as a cheatsheet for the author so he does not have to search Internet to find the installation steps.

```
$ initdb /usr/local/var/postgres -E utf8
The files belonging to this database system will be owned by user "jacek".
This user must also own the server process.

The database cluster will be initialized with locale "pl_pl.utf-8".
initdb: could not find suitable text search configuration for locale "pl_pl.utf-8"
The default text search configuration will be set to "simple".

Data page checksums are disabled.

creating directory /usr/local/var/postgres ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
creating template1 database in /usr/local/var/postgres/base/1 ... ok
initializing pg_authid ... ok
initializing dependencies ... ok
creating system views ... ok
loading system objects' descriptions ... ok
creating collations ... ok
creating conversions ... ok
creating dictionaries ... ok
setting privileges on built-in objects ... ok
creating information schema ... ok
loading PL/pgSQL server-side language ... ok
vacuuming database template1 ... ok
copying template1 to template0 ... ok
copying template1 to postgres ... ok
syncing data to disk ... ok

WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D /usr/local/var/postgres -l logfile start
```

==== [[starting-database-server]] Starting Database Server

NOTE: Consult http://www.postgresql.org/docs/current/static/server-start.html[17.3. Starting the Database Server] in the official documentation.

[TIP]
====
Enable `all` logs in PostgreSQL to see query statements.

```
log_statement = 'all'
```

Add `log_statement = 'all'` to `/usr/local/var/postgres/postgresql.conf` on Mac OS X with PostgreSQL installed using `brew`.
====

Start the database server using `pg_ctl`.

```
$ pg_ctl -D /usr/local/var/postgres -l logfile start
server starting
```

Alternatively, you can run the database server using `postgres`.

```
$ postgres -D /usr/local/var/postgres
```

==== [[creating-database]] Create Database

```
$ createdb sparkdb
```

TIP: Consult http://www.postgresql.org/docs/current/static/app-createdb.html[createdb] in the official documentation.

==== Accessing Database

Use `psql sparkdb` to access the database.

```
$ psql sparkdb
psql (9.6.2)
Type "help" for help.

sparkdb=#
```

Execute `SELECT version()` to know the version of the database server you have connected to.

```
sparkdb=# SELECT version();
                                                   version
--------------------------------------------------------------------------------------------------------------
 PostgreSQL 9.6.2 on x86_64-apple-darwin14.5.0, compiled by Apple LLVM version 7.0.2 (clang-700.1.81), 64-bit
(1 row)
```

Use `\h` for help and `\q` to leave a session.

==== Creating Table

Create a table using `CREATE TABLE` command.

```
CREATE TABLE projects (
  id SERIAL PRIMARY KEY,
  name text,
  website text
);
```

Insert rows to initialize the table with data.

```
INSERT INTO projects (name, website) VALUES ('Apache Spark', 'http://spark.apache.org');
INSERT INTO projects (name, website) VALUES ('Apache Hive', 'http://hive.apache.org');
INSERT INTO projects VALUES (DEFAULT, 'Apache Kafka', 'http://kafka.apache.org');
INSERT INTO projects VALUES (DEFAULT, 'Apache Flink', 'http://flink.apache.org');
```

Execute `select * from projects;` to ensure that you have the following records in `projects` table:

```
sparkdb=# select * from projects;
 id |     name     |         website
----+--------------+-------------------------
  1 | Apache Spark | http://spark.apache.org
  2 | Apache Hive  | http://hive.apache.org
  3 | Apache Kafka | http://kafka.apache.org
  4 | Apache Flink | http://flink.apache.org
(4 rows)
```

==== Dropping Database

```
$ dropdb sparkdb
```

TIP: Consult http://www.postgresql.org/docs/current/static/app-dropdb.html[dropdb] in the official documentation.

==== Stopping Database Server

```
pg_ctl -D /usr/local/var/postgres stop
```
