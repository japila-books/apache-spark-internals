# Broadcast

`Broadcast[T]` is an [abstraction](#contract) of [broadcast variables](#implementations) (with the [value](#value) of type `T`).

## Contract

### <span id="doDestroy"> Destroying Variable

```scala
doDestroy(
  blocking: Boolean): Unit
```

Destroys all the data and metadata related to this broadcast variable

Used when:

* `Broadcast` is requested to [destroy](#destroy)

### <span id="doUnpersist"> Unpersisting Variable

```scala
doUnpersist(
  blocking: Boolean): Unit
```

Deletes the cached copies of this broadcast value on executors

Used when:

* `Broadcast` is requested to [unpersist](#unpersist)

### <span id="getValue"> Broadcast Value

```scala
getValue(): T
```

Gets the broadcast value

Used when:

* `Broadcast` is requested for the [value](#value)

## Implementations

* [TorrentBroadcast](TorrentBroadcast.md)

## Creating Instance

`Broadcast` takes the following to be created:

* <span id="id"> Unique Identifier

??? note "Abstract Class"
    `Broadcast` is an abstract class and cannot be created directly. It is created indirectly for the [concrete Broadcasts](#implementations).

## <span id="Serializable"> Serializable

`Broadcast` is a `Serializable` ([Java]({{ java.api }}/java.base/java/io/Serializable.html)) so it can be serialized (_converted_ to bytes) and send over the wire from the driver to executors.

## <span id="destroy"> Destroying

```scala
destroy(): Unit // (1)
destroy(
  blocking: Boolean): Unit
```

1. Non-blocking destroy (`blocking` is `false`)

`destroy` removes persisted data and metadata associated with this broadcast variable.

!!! note
    Once a broadcast variable has been destroyed, it cannot be used again.

## <span id="unpersist"> Unpersisting

```scala
unpersist(): Unit // (1)
unpersist(
  blocking: Boolean): Unit
```

1. Non-blocking unpersist (`blocking` is `false`)

`unpersist`...FIXME

## <span id="value"> Brodcast Value

```scala
value: T
```

`value` [makes sure that it was not destroyed](#assertValid) and [gets the value](#getValue).

## <span id="toString"> Text Representation

```scala
toString: String
```

`toString` uses the [id](#id) as follows:

```text
Broadcast([id])
```

## <span id="assertValid"><span id="_isValid"> Validation

`Broadcast` is considered **valid** until [destroyed](#destroy).

`Broadcast` throws a `SparkException` (with the [text representation](#toString)) when [destroyed](#destroy) but requested for the [value](#value), to [unpersist](#unpersist) or [destroy](#destroy):

```text
Attempted to use [toString] after it was destroyed ([destroySite])
```
