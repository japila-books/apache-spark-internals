---
title: BarrierCoordinatorMessage
---

# BarrierCoordinatorMessage RPC Messages

`BarrierCoordinatorMessage` is an abstraction of [RPC messages](#implementations) that tasks can send out using [BarrierTaskContext](BarrierTaskContext.md#runBarrier) operators for [BarrierCoordinator](BarrierCoordinator.md) to handle.

`BarrierCoordinatorMessage` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)) (so it can be sent from executors to the driver over the wire).

## Implementations

??? note "Sealed Trait"
    `BarrierCoordinatorMessage` is a Scala **sealed trait** which means that all of the implementations are in the same compilation unit (a single file).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#sealed).

* [RequestToSync](RequestToSync.md)
