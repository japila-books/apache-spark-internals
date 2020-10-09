# Spillable

`Spillable` is an [extension](#contract) of the [MemoryConsumer](../memory/MemoryConsumer.md) abstraction for [spillable collections](#implementations) that can [spill to disk](#spill).

`Spillable[C]` is a parameterized type of `C` combiner (partial) values.

## Contract

### <span id="forceSpill"> forceSpill

```scala
forceSpill(): Boolean
```

Force spilling the current in-memory collection to disk to release memory.

Used when `Spillable` is requested to [spill](#spill)

### <span id="spill"> spill

```scala
spill(
  collection: C): Unit
```

Spills the current in-memory collection to disk, and releases the memory.

Used when:

* `ExternalAppendOnlyMap` is requested to [forceSpill](ExternalAppendOnlyMap.md#forceSpill)
* `Spillable` is requested to [spilling to disk if necessary](#maybeSpill)

## Implementations

* [ExternalAppendOnlyMap](ExternalAppendOnlyMap.md)
* [ExternalSorter](ExternalSorter.md)

## <span id="myMemoryThreshold"> Memory Threshold

`Spillable` uses a threshold for the memory size (in bytes) to know when to [spill to disk](#maybeSpill).

When the size of the in-memory collection is above the threshold, `Spillable` will try to acquire more memory. Unless given all requested memory, `Spillable` spills to disk.

The memory threshold starts as [spark.shuffle.spill.initialMemoryThreshold](#initialMemoryThreshold) configuration property and is increased every time `Spillable` is requested to [spill to disk if needed](#maybeSpill), but managed to acquire required memory. The threshold goes back to the [initial value](#initialMemoryThreshold) when requested to [release all memory](#releaseMemory).

Used when `Spillable` is requested to [spill](#spill) and [releaseMemory](#releaseMemory).

## Creating Instance

`Spillable` takes the following to be created:

* <span id="taskMemoryManager"> [TaskMemoryManager](../memory/TaskMemoryManager.md)

??? note "Abstract Class"
    `Spillable` is an abstract class and cannot be created directly. It is created indirectly for the [concrete Spillables](#implementations).

## Configuration Properties

### <span id="numElementsForceSpillThreshold"> spark.shuffle.spill.numElementsForceSpillThreshold

`Spillable` uses [spark.shuffle.spill.numElementsForceSpillThreshold](../configuration-properties.md#spark.shuffle.spill.numElementsForceSpillThreshold) configuration property to force spilling in-memory objects to disk when requested to [maybeSpill](#maybeSpill).

### <span id="initialMemoryThreshold"> spark.shuffle.spill.initialMemoryThreshold

`Spillable` uses [spark.shuffle.spill.initialMemoryThreshold](../configuration-properties.md#spark.shuffle.spill.initialMemoryThreshold) configuration property as the initial threshold for the size of a collection (and the minimum memory required to operate properly).

`Spillable` uses it when requested to [spill](#spill) and [releaseMemory](#releaseMemory).

## <span id="releaseMemory"> Releasing All Memory

```scala
releaseMemory(): Unit
```

`releaseMemory`...FIXME

`releaseMemory` is used when:

* `ExternalAppendOnlyMap` is requested to [freeCurrentMap](ExternalAppendOnlyMap.md#freeCurrentMap)
* `ExternalSorter` is requested to [stop](ExternalSorter.md#stop)
* `Spillable` is requested to [maybeSpill](#maybeSpill) and [spill](#spill) (and spilled to disk in either case)

## <span id="spill"> Spilling In-Memory Collection to Disk (to Release Memory)

```scala
spill(
  collection: C): Unit
```

`spill` spills the given in-memory collection to disk to release memory.

`spill` is used when:

* `ExternalAppendOnlyMap` is requested to [forceSpill](ExternalAppendOnlyMap.md#forceSpill)
* `Spillable` is requested to [maybeSpill](#maybeSpill)

## <span id="forceSpill"> forceSpill

```scala
forceSpill(): Boolean
```

`forceSpill` forcefully spills the Spillable to disk to release memory.

`forceSpill` is used when `Spillable` is requested to [spill an in-memory collection to disk](#spill).

## <span id="maybeSpill"> Spilling to Disk if Necessary

```scala
maybeSpill(
  collection: C,
  currentMemory: Long): Boolean
```

`maybeSpill`...FIXME

`maybeSpill` is used when:

* `ExternalAppendOnlyMap` is requested to [insertAll](ExternalAppendOnlyMap.md#insertAll)
* `ExternalSorter` is requested to [attempt to spill an in-memory collection to disk if needed](ExternalSorter.md#maybeSpillCollection)
