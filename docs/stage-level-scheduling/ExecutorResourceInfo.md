# ExecutorResourceInfo

`ExecutorResourceInfo` is a [ResourceAllocator](ResourceAllocator.md).

## Creating Instance

`ExecutorResourceInfo` takes the following to be created:

* <span id="name"> Resource Name
* <span id="addresses"> Addresses
* <span id="numParts"> Number of slots (per address)

`ExecutorResourceInfo` is created when:

* `DriverEndpoint` is requested to [handle a RegisterExecutor event](../scheduler/DriverEndpoint.md#RegisterExecutor)
