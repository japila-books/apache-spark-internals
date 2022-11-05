# ShuffleHandle

`ShuffleHandle` is an abstraction of [shuffle handles](#implementations) for [ShuffleManager](ShuffleManager.md) to pass information about shuffles to tasks.

`ShuffleHandle` is `Serializable` ([Java]({{ java.api }}/java/io/Serializable)).

## Implementations

* [BaseShuffleHandle](BaseShuffleHandle.md)

## Creating Instance

`ShuffleHandle` takes the following to be created:

* <span id="shuffleId"> Shuffle ID

!!! note "Abstract Class"
    `ShuffleHandle` is an abstract class and cannot be created directly. It is created indirectly for the [concrete ShuffleHandles](#implementations).
