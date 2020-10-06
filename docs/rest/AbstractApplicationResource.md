== [[AbstractApplicationResource]] AbstractApplicationResource

`AbstractApplicationResource` is a spark-api-BaseAppResource.md[BaseAppResource] with a set of <<paths, URI paths>> that are common across <<implementations, implementations>>.

```
// start spark-shell
$ http http://localhost:4040/api/v1/applications
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 257
Content-Type: application/json
Date: Tue, 05 Jun 2018 18:46:32 GMT
Server: Jetty(9.3.z-SNAPSHOT)
Vary: Accept-Encoding, User-Agent

[
    {
        "attempts": [
            {
                "appSparkVersion": "2.3.1-SNAPSHOT",
                "completed": false,
                "duration": 0,
                "endTime": "1969-12-31T23:59:59.999GMT",
                "endTimeEpoch": -1,
                "lastUpdated": "2018-06-05T15:04:48.328GMT",
                "lastUpdatedEpoch": 1528211088328,
                "sparkUser": "jacek",
                "startTime": "2018-06-05T15:04:48.328GMT",
                "startTimeEpoch": 1528211088328
            }
        ],
        "id": "local-1528211089216",
        "name": "Spark shell"
    }
]

$ http http://localhost:4040/api/v1/applications/local-1528211089216/storage/rdd
HTTP/1.1 200 OK
Content-Length: 3
Content-Type: application/json
Date: Tue, 05 Jun 2018 18:48:00 GMT
Server: Jetty(9.3.z-SNAPSHOT)
Vary: Accept-Encoding, User-Agent

[]

// Execute the following query in spark-shell
spark.range(5).cache.count

$ http http://localhost:4040/api/v1/applications/local-1528211089216/storage/rdd
// output omitted for brevity
```

[[implementations]]
.AbstractApplicationResources
[cols="1,2",options="header",width="100%"]
|===
| AbstractApplicationResource
| Description

| spark-api-OneApplicationResource.md[OneApplicationResource]
| [[OneApplicationResource]] Handles `applications/appId` requests

| spark-api-OneApplicationAttemptResource.md[OneApplicationAttemptResource]
| [[OneApplicationAttemptResource]]
|===

[[paths]]
.AbstractApplicationResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

| `allexecutors`
| GET
| <<allExecutorList, allExecutorList>>

| `environment`
| GET
| <<environmentInfo, environmentInfo>>

| `executors`
| GET
| <<executorList, executorList>>

| `jobs`
| GET
| <<jobsList, jobsList>>

| `jobs/{jobId: \\d+}`
| GET
| <<oneJob, oneJob>>

| `logs`
| GET
| <<getEventLogs, getEventLogs>>

| `stages`
|
| <<stages, stages>>

| `storage/rdd/{rddId: \\d+}`
| GET
| <<rddData, rddData>>

| [[storage_rdd]] `storage/rdd`
| GET
| <<rddList, rddList>>
|===

=== [[rddList]] `rddList` Method

[source, scala]
----
rddList(): Seq[RDDStorageInfo]
----

`rddList`...FIXME

NOTE: `rddList` is used when...FIXME

=== [[environmentInfo]] `environmentInfo` Method

[source, scala]
----
environmentInfo(): ApplicationEnvironmentInfo
----

`environmentInfo`...FIXME

NOTE: `environmentInfo` is used when...FIXME

=== [[rddData]] `rddData` Method

[source, scala]
----
rddData(@PathParam("rddId") rddId: Int): RDDStorageInfo
----

`rddData`...FIXME

NOTE: `rddData` is used when...FIXME

=== [[allExecutorList]] `allExecutorList` Method

[source, scala]
----
allExecutorList(): Seq[ExecutorSummary]
----

`allExecutorList`...FIXME

NOTE: `allExecutorList` is used when...FIXME

=== [[executorList]] `executorList` Method

[source, scala]
----
executorList(): Seq[ExecutorSummary]
----

`executorList`...FIXME

NOTE: `executorList` is used when...FIXME

=== [[oneJob]] `oneJob` Method

[source, scala]
----
oneJob(@PathParam("jobId") jobId: Int): JobData
----

`oneJob`...FIXME

NOTE: `oneJob` is used when...FIXME

=== [[jobsList]] `jobsList` Method

[source, scala]
----
jobsList(@QueryParam("status") statuses: JList[JobExecutionStatus]): Seq[JobData]
----

`jobsList`...FIXME

NOTE: `jobsList` is used when...FIXME
