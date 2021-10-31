# ExecutorDeadException

`ExecutorDeadException` is a `SparkException`.

## Creating Instance

`ExecutorDeadException` takes the following to be created:

* <span id="message"> Error message

`ExecutorDeadException` is created when:

* `NettyBlockTransferService` is requested to [fetch blocks](storage/NettyBlockTransferService.md#fetchBlocks)
