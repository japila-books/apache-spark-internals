# ShuffleFetchCompletionListener

`ShuffleFetchCompletionListener` is a [TaskCompletionListener](../TaskCompletionListener.md).

## <span id="onTaskCompletion"><span id="onComplete"> onTaskCompletion

```scala
onTaskCompletion(
  context: TaskContext): Unit
```

`onTaskCompletion` is part of the [TaskCompletionListener](../TaskCompletionListener.md#onTaskCompletion) abstraction.

`onTaskCompletion` requests the [ShuffleBlockFetcherIterator](#data) (if available) to [cleanup](ShuffleBlockFetcherIterator.md#cleanup).

In the end, `onTaskCompletion` nulls out the reference to the [ShuffleBlockFetcherIterator](#data) (to make it available for garbage collection).
