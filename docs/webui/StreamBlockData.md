# StreamBlockData

`StreamBlockData` holds a metadata of a [StreamBlockId](../storage/BlockId.md#StreamBlockId):

* <span id="name"> Name
* <span id="executorId"> Executor ID
* <span id="hostPort"> Host Port
* <span id="storageLevel"> Storage Level
* <span id="useMemory"> `useMemory` flag
* <span id="useDisk"> `useDisk` flag
* <span id="deserialized"> `deserialized` flag
* <span id="memSize"> Memory Size
* <span id="diskSize"> Disk Size

`StreamBlockData` is created when:

* `AppStatusListener` is requested to [update a StreamBlock](../AppStatusListener.md#updateStreamBlock)
