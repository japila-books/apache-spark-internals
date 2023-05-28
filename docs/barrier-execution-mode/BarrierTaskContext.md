---
title: BarrierTaskContext
---

# BarrierTaskContext &mdash; TaskContext for Barrier Tasks

`BarrierTaskContext` is a concrete [TaskContext](../scheduler/TaskContext.md) (of the tasks) of [barrier stages](index.md#barrier-stage).

## Creating Instance

`BarrierTaskContext` takes the following to be created:

* <span id="taskContext"> [TaskContext](../scheduler/TaskContext.md)

`BarrierTaskContext` is created when:

* `Task` is requested to [run](../scheduler/Task.md#run) (with [isBarrier](../scheduler/Task.md#isBarrier) flag enabled)

## RpcEndpointRef { #barrierCoordinator }

`BarrierTaskContext` creates an [RpcEndpointRef](../rpc/RpcEndpointRef.md) for...FIXME
