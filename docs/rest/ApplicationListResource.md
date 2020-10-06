== [[ApplicationListResource]] ApplicationListResource -- applications URI Handler

`ApplicationListResource` is a spark-api-ApiRequestContext.md[ApiRequestContext] that spark-api-ApiRootResource.md#applications[ApiRootResource] uses to handle <<root, applications>> URI path.

[[paths]]
.ApplicationListResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

| [[root]] `/`
| GET
| <<appList, appList>>
|===

```
// start spark-shell
// there should be a single Spark application -- the spark-shell itself
$ http http://localhost:4040/api/v1/applications
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 255
Content-Type: application/json
Date: Wed, 06 Jun 2018 12:40:33 GMT
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
                "lastUpdated": "2018-06-06T12:30:19.220GMT",
                "lastUpdatedEpoch": 1528288219220,
                "sparkUser": "jacek",
                "startTime": "2018-06-06T12:30:19.220GMT",
                "startTimeEpoch": 1528288219220
            }
        ],
        "id": "local-1528288219790",
        "name": "Spark shell"
    }
]
```

=== [[isAttemptInRange]] `isAttemptInRange` Internal Method

[source, scala]
----
isAttemptInRange(
  attempt: ApplicationAttemptInfo,
  minStartDate: SimpleDateParam,
  maxStartDate: SimpleDateParam,
  minEndDate: SimpleDateParam,
  maxEndDate: SimpleDateParam,
  anyRunning: Boolean): Boolean
----

`isAttemptInRange`...FIXME

NOTE: `isAttemptInRange` is used exclusively when `ApplicationListResource` is requested to handle a <<appList, GET />> HTTP request.

=== [[appList]] `appList` Method

[source, scala]
----
appList(
  @QueryParam("status") status: JList[ApplicationStatus],
  @DefaultValue("2010-01-01") @QueryParam("minDate") minDate: SimpleDateParam,
  @DefaultValue("3000-01-01") @QueryParam("maxDate") maxDate: SimpleDateParam,
  @DefaultValue("2010-01-01") @QueryParam("minEndDate") minEndDate: SimpleDateParam,
  @DefaultValue("3000-01-01") @QueryParam("maxEndDate") maxEndDate: SimpleDateParam,
  @QueryParam("limit") limit: Integer)
: Iterator[ApplicationInfo]
----

`appList`...FIXME

NOTE: `appList` is used when...FIXME
