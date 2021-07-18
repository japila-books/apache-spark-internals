# BlockManagerDecommissioner

`BlockManagerDecommissioner` is a decommissioning process used by [BlockManager](BlockManager.md#decommissioner).

## Creating Instance

`BlockManagerDecommissioner` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="bm"> [BlockManager](BlockManager.md)

`BlockManagerDecommissioner` is created when:

* `BlockManager` is requested to [decommissionSelf](BlockManager.md#decommissionSelf)
