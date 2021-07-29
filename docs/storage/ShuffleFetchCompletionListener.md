# ShuffleFetchCompletionListener

`ShuffleFetchCompletionListener` is a [TaskCompletionListener](../TaskCompletionListener.md) (that [ShuffleBlockFetcherIterator](#data) uses to [clean up](ShuffleBlockFetcherIterator.md#cleanup) after the owning task is completed).

## Creating Instance

`ShuffleFetchCompletionListener` takes the following to be created:

* <span id="data"> [ShuffleBlockFetcherIterator](ShuffleBlockFetcherIterator.md)

`ShuffleFetchCompletionListener` is created when:

* `ShuffleBlockFetcherIterator` is [created](ShuffleBlockFetcherIterator.md#onCompleteCallback)

## <span id="onTaskCompletion"><span id="onComplete"> onTaskCompletion

```scala
onTaskCompletion(
  context: TaskContext): Unit
```

`onTaskCompletion` is part of the [TaskCompletionListener](../TaskCompletionListener.md#onTaskCompletion) abstraction.

`onTaskCompletion` requests the [ShuffleBlockFetcherIterator](#data) (if available) to [cleanup](ShuffleBlockFetcherIterator.md#cleanup).

In the end, `onTaskCompletion` nulls out the reference to the [ShuffleBlockFetcherIterator](#data) (to make it available for garbage collection).
