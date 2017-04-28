== [[Catalyst]] Catalyst -- Tree Manipulation Framework

*Catalyst* is an execution-agnostic framework to represent and manipulate a *dataflow graph*, i.e. trees of link:spark-sql-catalyst-QueryPlan.adoc[relational operators] and link:spark-sql-Expression.adoc[expressions].

NOTE: The Catalyst framework were first introduced in https://issues.apache.org/jira/browse/SPARK-1251[SPARK-1251 Support for optimizing and executing structured queries] and became part of Apache Spark on 20/Mar/14 19:12.

The main abstraction in Catalyst is link:spark-sql-catalyst-TreeNode.adoc[TreeNode] that is then used to build trees of link:spark-sql-Expression.adoc[Expressions] or link:spark-sql-catalyst-QueryPlan.adoc[QueryPlans].

Spark 2.0 uses the Catalyst tree manipulation framework to build an extensible *query plan optimizer* with a number of query optimizations.

Catalyst supports both rule-based and cost-based optimization.
