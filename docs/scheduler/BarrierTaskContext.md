# BarrierTaskContext -- TaskContext for Barrier Tasks

BarrierTaskContext is a concrete [TaskContext](TaskContext.md) that is <<creating-instance, created>> exclusively when `Task` is requested to scheduler:Task.md#run[run] and the task is scheduler:Task.md#isBarrier[isBarrier] (when `Executor` is requested to executor:Executor.md#launchTask[launch a task (on "Executor task launch worker" thread pool) sometime in the future]).

[[creating-instance]]
[[taskContext]]
BarrierTaskContext takes a single [TaskContext](TaskContext.md) to be created.

=== [[barrierCoordinator]] RpcEndpointRef

BarrierTaskContext creates an RpcEndpointRef for...FIXME
