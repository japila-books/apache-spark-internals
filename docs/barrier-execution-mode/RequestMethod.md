# RequestMethod

`RequestMethod` represents the allowed request methods of [RequestToSync](RequestToSync.md#requestMethod)s (that are sent out from barrier tasks using [BarrierTaskContext](BarrierTaskContext.md#runBarrier)).

[ContextBarrierState](ContextBarrierState.md#requestMethods) tracks `RequestMethod`s (from tasks inside a barrier sync) to make sure that the tasks are all part of a legitimate barrier sync. All tasks should make sure that they're calling the same method within the same barrier sync phase.

## BARRIER { #BARRIER }

Marks execution of [BarrierTaskContext.barrier](BarrierTaskContext.md#barrier)

## ALL_GATHER { #ALL_GATHER }

Marks execution of [BarrierTaskContext.allGather](BarrierTaskContext.md#allGather)
