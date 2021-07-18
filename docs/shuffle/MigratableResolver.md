# MigratableResolver

`MigratableResolver` is an [abstraction](#contract) of [resolvers](#implementations) that allow Spark to migrate shuffle blocks.

## Contract

### <span id="getMigrationBlocks"> getMigrationBlocks

```scala
getMigrationBlocks(
  shuffleBlockInfo: ShuffleBlockInfo): List[(BlockId, ManagedBuffer)]
```

Used when:

* `ShuffleMigrationRunnable` is requested to [run](../storage/ShuffleMigrationRunnable.md#run)

### <span id="getStoredShuffles"> getStoredShuffles

```scala
getStoredShuffles(): Seq[ShuffleBlockInfo]
```

Used when:

* `BlockManagerDecommissioner` is requested to [refreshOffloadingShuffleBlocks](../storage/BlockManagerDecommissioner.md#refreshOffloadingShuffleBlocks)

### <span id="putShuffleBlockAsStream"> putShuffleBlockAsStream

```scala
putShuffleBlockAsStream(
  blockId: BlockId,
  serializerManager: SerializerManager): StreamCallbackWithID
```

Used when:

* `BlockManager` is requested to [putBlockDataAsStream](../storage/BlockManager.md#putBlockDataAsStream)

## Implementations

* [IndexShuffleBlockResolver](IndexShuffleBlockResolver.md)
