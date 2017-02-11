== [[AccumulatorContext]] AccumulatorContext

`AccumulatorContext` is a `private[spark]` internal object used to track accumulators by Spark itself using an internal `originals` lookup table. Spark uses the `AccumulatorContext` object to register and unregister accumulators.

The `originals` lookup table maps accumulator identifier to the accumulator itself.

Every accumulator has its own unique accumulator id that is assigned using the internal `nextId` counter.

=== [[register]] `register` Method

CAUTION: FIXME

=== [[newId]] `newId` Method

CAUTION: FIXME

=== [[AccumulatorContext-SQL_ACCUM_IDENTIFIER]] AccumulatorContext.SQL_ACCUM_IDENTIFIER

`AccumulatorContext.SQL_ACCUM_IDENTIFIER` is an internal identifier for Spark SQL's internal accumulators. The value is `sql` and Spark uses it to distinguish link:spark-sql-SparkPlan.adoc#SQLMetric[Spark SQL metrics] from others.
