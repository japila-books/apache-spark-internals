# SparkUITab

`SparkUITab` is an extension of the [WebUITab](WebUITab.md) abstraction for [UI tabs](#implementations) with the [application name](#appName) and [Spark version](#appSparkVersion).

## Implementations

* [EnvironmentTab](EnvironmentTab.md)
* [ExecutorsTab](ExecutorsTab.md)
* [JobsTab](JobsTab.md)
* [StagesTab](StagesTab.md)
* [StorageTab](StorageTab.md)

## Creating Instance

`SparkUITab` takes the following to be created:

* <span id="parent"> Parent [SparkUI](SparkUI.md)
* <span id="prefix"> URL Prefix

??? note "Abstract Class"
    `SparkUITab` is an abstract class and cannot be created directly. It is created indirectly for the [concrete SparkUITabs](#implementations).

## <span id="appName"> Application Name

```scala
appName: String
```

`appName` requests the [parent SparkUI](#parent) for the [appName](SparkUI.md#appName).

## <span id="appSparkVersion"> Spark Version

```scala
appSparkVersion: String
```

`appSparkVersion` requests the [parent SparkUI](#parent) for the [appSparkVersion](SparkUI.md#appSparkVersion).
