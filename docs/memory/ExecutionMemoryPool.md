# ExecutionMemoryPool

`ExecutionMemoryPool` is a [MemoryPool](MemoryPool.md).

## Creating Instance

`ExecutionMemoryPool` takes the following to be created:

* <span id="lock"> Lock Object
* <span id="memoryMode"> `MemoryMode` (`ON_HEAP` or `OFF_HEAP`)

`ExecutionMemoryPool` is created when:

* `MemoryManager` is created (and initializes [on-heap](MemoryManager.md#onHeapExecutionMemoryPool) and [off-heap](MemoryManager.md#offHeapExecutionMemoryPool) execution memory pools)

## <span id="acquireMemory"> Acquiring Memory

```scala
acquireMemory(
  numBytes: Long,
  taskAttemptId: Long,
  maybeGrowPool: Long => Unit = (additionalSpaceNeeded: Long) => (),
  computeMaxPoolSize: () => Long = () => poolSize): Long
```

`acquireMemory`...FIXME

`acquireMemory` is used when:

* `UnifiedMemoryManager` is requested to [acquire execution memory](UnifiedMemoryManager.md#acquireExecutionMemory)
