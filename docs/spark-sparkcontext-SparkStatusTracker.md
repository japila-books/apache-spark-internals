= SparkStatusTracker

`SparkStatusTracker` is...FIXME

`SparkStatusTracker` is <<creating-instance, created>> when `SparkContext` link:spark-SparkContext-creating-instance-internals.adoc#_statusTracker[is created].

== [[creating-instance]] Creating SparkStatusTracker Instance

`SparkStatusTracker` takes the following when created:

* [[sc]] xref:ROOT:SparkContext.adoc[]
* [[store]] xref:core:AppStatusStore.adoc[]
