== Operators - Transformations and Actions

RDDs have two types of operations: link:spark-rdd-transformations.adoc[transformations] and link:spark-rdd-actions.adoc[actions].

NOTE: Operators are also called *operations*.

=== Gotchas - things to watch for

Even if you don't access it explicitly it cannot be referenced inside a closure as it is serialized and carried around across executors.

See https://issues.apache.org/jira/browse/SPARK-5063
