= SparkStatusTracker

`SparkStatusTracker` is...FIXME

`SparkStatusTracker` is <<creating-instance, created>> when `SparkContext` spark-SparkContext-creating-instance-internals.md#_statusTracker[is created].

== [[creating-instance]] Creating SparkStatusTracker Instance

`SparkStatusTracker` takes the following when created:

* [[sc]] ROOT:SparkContext.md[]
* [[store]] core:AppStatusStore.md[]
