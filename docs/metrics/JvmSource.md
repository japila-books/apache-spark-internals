# JvmSource

`JvmSource` is a [metrics source](Source.md).

<span id="sourceName">
The name of the source is **jvm**.

`JvmSource` registers the build-in Codahale metrics:

* `GarbageCollectorMetricSet`
* `MemoryUsageGaugeSet`
* `BufferPoolMetricSet`

Among the metrics is **total.committed** (from `MemoryUsageGaugeSet`) that describes the current usage of the heap and non-heap memories.
