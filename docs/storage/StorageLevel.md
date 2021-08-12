---
tags:
  - DeveloperApi
---

# StorageLevel

`StorageLevel` is the following flags for controlling the storage of an [RDD](../rdd/RDD.md).

Flag | Default Value
-----|--------------
 <span id="_useDisk"><span id="useDisk"> `useDisk` | `false`
 <span id="_useMemory"><span id="useMemory"> `useMemory` | `true`
 <span id="_useOffHeap"><span id="useOffHeap"> `useOffHeap` | `false`
 <span id="_deserialized"><span id="deserialized"> `deserialized` | `false`
 <span id="_replication"><span id="replication"> `replication` | 1

## Restrictions

1. The [replication](#replication) is restricted to be less than `40` (for calculating the hash code)
1. [Off-heap storage level](#useOffHeap) does not support [deserialized](#deserialized) storage

## <span id="isValid"> Validation

```scala
isValid: Boolean
```

`StorageLevel` is considered **valid** when the following all hold:

1. Uses [memory](#useMemory) or [disk](#useDisk)
1. [Replication](#replication) is non-zero positive number (between the default `1` and [40](#restrictions))

## <span id="Externalizable"> Externalizable

`DirectTaskResult` is an `Externalizable` ([Java]({{ java.api }}/java.base/java/io/Externalizable.html)).

### <span id="writeExternal"> writeExternal

```scala
writeExternal(
  out: ObjectOutput): Unit
```

`writeExternal` is part of the `Externalizable` ([Java]({{ java.api }}/java.base/java/io/Externalizable.html#writeExternal(java.io.ObjectOutput))) abstraction.

`writeExternal` writes the [bitwise representation](#toInt) out followed by the [replication](#_replication) of this `StorageLevel`.

## <span id="toInt"> Bitwise Integer Representation

```scala
toInt: Int
```

`toInt` converts this `StorageLevel` to numeric (binary) representation by turning the corresponding bits on for the following (if used and in that order):

1. [deserialized](#_deserialized)
1. [useOffHeap](#_useOffHeap)
1. [useMemory](#_useMemory)
1. [useDisk](#_useDisk)

In other words, the following number in bitwise representation says the `StorageLevel` is [deserialized](#_deserialized) and [useMemory](#_useMemory):

```scala
import org.apache.spark.storage.StorageLevel.MEMORY_ONLY
assert(MEMORY_ONLY.toInt == (0 | 1 | 4))

scala> println(MEMORY_ONLY.toInt.toBinaryString)
101
```

`toInt` is used when:

* `StorageLevel` is requested to [writeExternal](#writeExternal) and [hashCode](#hashCode)
