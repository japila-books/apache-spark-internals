== [[OneApplicationAttemptResource]] OneApplicationAttemptResource

`OneApplicationAttemptResource` is a link:spark-api-AbstractApplicationResource.adoc[AbstractApplicationResource] (and so a link:spark-api-ApiRequestContext.adoc[ApiRequestContext] indirectly).

`OneApplicationAttemptResource` is used when `AbstractApplicationResource` is requested to link:spark-api-AbstractApplicationResource.adoc#applicationAttempt[applicationAttempt].

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

`getAttempt` requests the link:spark-api-ApiRequestContext.adoc#uiRoot[UIRoot] for the link:spark-api-UIRoot.adoc#getApplicationInfo[application info] (given the link:spark-api-BaseAppResource.adoc#appId[appId]) and finds the link:spark-api-BaseAppResource.adoc#attemptId[attemptId] among the available attempts.

NOTE: link:spark-api-BaseAppResource.adoc#appId[appId] and link:spark-api-BaseAppResource.adoc#attemptId[attemptId] are path parameters.

In the end, `getAttempt` returns the `ApplicationAttemptInfo` if available or reports a `NotFoundException`:

```
unknown app [appId], attempt [attemptId]
```
