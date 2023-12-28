# BroadcastFactory

`BroadcastFactory` is an [abstraction](#contract) of [broadcast variable factories](#implementations) that [BroadcastManager](BroadcastManager.md) uses to [create](#newBroadcast) or [delete](#unbroadcast) (_unbroadcast_) broadcast variables.

## Contract

### Initializing { #initialize }

```scala
initialize(
  isDriver: Boolean,
  conf: SparkConf): Unit
```

??? warning "Procedure"
    `initialize` is a procedure (returns `Unit`) so _what happens inside stays inside_ (paraphrasing the [former advertising slogan of Las Vegas, Nevada](https://idioms.thefreedictionary.com/what+happens+in+Vegas+stays+in+Vegas)).

See:

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md#initialize)

Used when:

* `BroadcastManager` is requested to [initialize](BroadcastManager.md#initialize)

### Creating Broadcast Variable { #newBroadcast }

```scala
newBroadcast[T: ClassTag](
  value: T,
  isLocal: Boolean,
  id: Long,
  serializedOnly: Boolean = false): Broadcast[T]
```

See:

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md#newBroadcast)

Used when:

* `BroadcastManager` is requested for a [new broadcast variable](BroadcastManager.md#newBroadcast)

### Stopping { #stop }

```scala
stop(): Unit
```

??? warning "Procedure"
    `stop` is a procedure (returns `Unit`) so _what happens inside stays inside_ (paraphrasing the [former advertising slogan of Las Vegas, Nevada](https://idioms.thefreedictionary.com/what+happens+in+Vegas+stays+in+Vegas)).

See:

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md#stop)

Used when:

* `BroadcastManager` is requested to [stop](BroadcastManager.md#stop)

### Deleting Broadcast Variable { #unbroadcast }

```scala
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
```

??? warning "Procedure"
    `unbroadcast` is a procedure (returns `Unit`) so _what happens inside stays inside_ (paraphrasing the [former advertising slogan of Las Vegas, Nevada](https://idioms.thefreedictionary.com/what+happens+in+Vegas+stays+in+Vegas)).

See:

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md#unbroadcast)

Used when:

* `BroadcastManager` is requested to [delete a broadcast variable](BroadcastManager.md#unbroadcast) (_unbroadcast_)

## Implementations

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md)
