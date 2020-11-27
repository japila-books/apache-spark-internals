# ExecutorAllocationClient

`ExecutorAllocationClient` is a <<contract, contract>> for clients to communicate with a cluster manager to request or kill executors.

=== [[contract]] ExecutorAllocationClient Contract

[source, scala]
----
trait ExecutorAllocationClient {
  def getExecutorIds(): Seq[String]
  def requestTotalExecutors(numExecutors: Int, localityAwareTasks: Int, hostToLocalTaskCount: Map[String, Int]): Boolean
  def requestExecutors(numAdditionalExecutors: Int): Boolean
  def killExecutor(executorId: String): Boolean
  def killExecutors(executorIds: Seq[String]): Seq[String]
  def killExecutorsOnHost(host: String): Boolean
}
----

NOTE: `ExecutorAllocationClient` is a `private[spark]` contract.

.ExecutorAllocationClient Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| [[getExecutorIds]] `getExecutorIds`
| Finds identifiers of the executors in use.

Used when [`SparkContext` calculates the executors in use](../SparkContext.md#getExecutorIds)

| [[requestTotalExecutors]] `requestTotalExecutors`
a| Updates the cluster manager with the exact number of executors desired. It returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* [`SparkContext` requests executors](../SparkContext.md#requestTotalExecutors) (for coarse-grained scheduler backends only).

* `ExecutorAllocationManager` [starts](ExecutorAllocationManager.md#start), does [updateAndSyncNumExecutorsTarget](ExecutorAllocationManager.md#updateAndSyncNumExecutorsTarget), and [addExecutors](ExecutorAllocationManager.md#addExecutors).

| [[requestExecutors]] `requestExecutors`
| Requests additional executors from a cluster manager and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when [`SparkContext` requests additional executors](../SparkContext.md#requestExecutors) (for coarse-grained scheduler backends only).

| [[killExecutor]] `killExecutor`
a| Requests a cluster manager to kill a single executor that is no longer in use and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

The default implementation simply calls <<killExecutors, killExecutors>> (with a single-element collection of executors to kill).

Used when:

* `ExecutorAllocationManager` [removes an executor](ExecutorAllocationManager.md#removeExecutor).

* `SparkContext` [is requested to kill executors](../SparkContext.md#killExecutors).

| [[killExecutors]] `killExecutors`
| Requests that a cluster manager to kill one or many executors that are no longer in use and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

_Interestingly_, it is only used for <<killExecutor, killExecutor>>.

| [[killExecutorsOnHost]] `killExecutorsOnHost`
| Used exclusively when `BlacklistTracker` kills blacklisted executors.

|===
