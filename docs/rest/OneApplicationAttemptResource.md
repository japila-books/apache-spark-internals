== [[OneApplicationAttemptResource]] OneApplicationAttemptResource

`OneApplicationAttemptResource` is a spark-api-AbstractApplicationResource.md[AbstractApplicationResource] (and so a spark-api-ApiRequestContext.md[ApiRequestContext] indirectly).

`OneApplicationAttemptResource` is used when `AbstractApplicationResource` is requested to spark-api-AbstractApplicationResource.md#applicationAttempt[applicationAttempt].

[[paths]]
.OneApplicationAttemptResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

| [[root]] `/`
| GET
| <<getAttempt, getAttempt>>
|===

```
// start spark-shell
// there should be a single Spark application -- the spark-shell itself
// CAUTION: FIXME Demo of OneApplicationAttemptResource in Action
```

=== [[getAttempt]] `getAttempt` Method

[source, scala]
----
getAttempt(): ApplicationAttemptInfo
----

`getAttempt` requests the spark-api-ApiRequestContext.md#uiRoot[UIRoot] for the spark-api-UIRoot.md#getApplicationInfo[application info] (given the spark-api-BaseAppResource.md#appId[appId]) and finds the spark-api-BaseAppResource.md#attemptId[attemptId] among the available attempts.

NOTE: spark-api-BaseAppResource.md#appId[appId] and spark-api-BaseAppResource.md#attemptId[attemptId] are path parameters.

In the end, `getAttempt` returns the `ApplicationAttemptInfo` if available or reports a `NotFoundException`:

```
unknown app [appId], attempt [attemptId]
```
