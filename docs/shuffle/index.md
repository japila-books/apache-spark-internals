# Shuffle System

**Shuffle System** is a core component of Apache Spark that is responsible for shuffle block management.

The core abstraction is [ShuffleManager](ShuffleManager.md) with the default and only known implementation being [SortShuffleManager](SortShuffleManager.md).

## Resources

* [Improving Apache Spark Downscaling](https://databricks.com/session_eu19/improving-apache-spark-downscaling) by Christopher Crosbie (Google) Ben Sidhom (Google)
* [Spark shuffle introduction](http://www.slideshare.net/colorant/spark-shuffle-introduction) by Raymond Liu (aka _colorant_)
