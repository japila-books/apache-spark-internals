# ResourceAllocator

`ResourceAllocator` is an [abstraction](#contract) of [resource allocators](#implementations).

## Contract

### <span id="resourceAddresses"> resourceAddresses

```scala
resourceAddresses: Seq[String]
```

Used when:

* `ResourceAllocator` is requested for the [addressAvailabilityMap](#addressAvailabilityMap)

### <span id="resourceName"> resourceName

```scala
resourceName: String
```

Used when:

* `ResourceAllocator` is requested to [acquire](#acquire) and [release](#release) addresses

### <span id="slotsPerAddress"> slotsPerAddress

```scala
slotsPerAddress: Int
```

Used when:

* `ResourceAllocator` is requested for the [addressAvailabilityMap](#addressAvailabilityMap), [assignedAddrs](#assignedAddrs) and to [release](#release)

## Implementations

* [ExecutorResourceInfo](ExecutorResourceInfo.md)
* `WorkerResourceInfo` ([Spark Standalone]({{ book.spark_standalone }}))

## <span id="acquire"> Acquiring Addresses

```scala
acquire(
  addrs: Seq[String]): Unit
```

`acquire`...FIXME

`acquire` is used when:

* `DriverEndpoint` is requested to [launchTasks](../scheduler/DriverEndpoint.md#launchTasks)
* `WorkerResourceInfo` (Spark Standalone) is requested to `acquire` and `recoverResources`

## <span id="release"> Releasing Addresses

```scala
release(
  addrs: Seq[String]): Unit
```

`release`...FIXME

`release` is used when:

* `DriverEndpoint` is requested to [handle a StatusUpdate event](../scheduler/DriverEndpoint.md#StatusUpdate)
* `WorkerInfo` (Spark Standalone) is requested to `releaseResources`

## <span id="assignedAddrs"> assignedAddrs

```scala
assignedAddrs: Seq[String]
```

`assignedAddrs`...FIXME

`assignedAddrs` is used when:

* `WorkerInfo` (Spark Standalone) is requested for the `resourcesInfoUsed`

## <span id="availableAddrs"> availableAddrs

```scala
availableAddrs: Seq[String]
```

`availableAddrs`...FIXME

`availableAddrs` is used when:

* `WorkerInfo` (Spark Standalone) is requested for the `resourcesInfoFree`
* `WorkerResourceInfo` (Spark Standalone) is requested to `acquire` and `resourcesAmountFree`
* `DriverEndpoint` is requested to [makeOffers](../scheduler/DriverEndpoint.md#makeOffers)

## <span id="addressAvailabilityMap"> addressAvailabilityMap

```scala
addressAvailabilityMap: Seq[String]
```

`addressAvailabilityMap`...FIXME

??? note "Lazy Value"
    `addressAvailabilityMap` is a Scala **lazy value** to guarantee that the code to initialize it is executed once only (when accessed for the first time) and the computed value never changes afterwards.

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#lazy).

`addressAvailabilityMap` is used when:

* `ResourceAllocator` is requested to [availableAddrs](#availableAddrs), [assignedAddrs](#assignedAddrs), [acquire](#acquire), [release](#release)
