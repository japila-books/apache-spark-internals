== [[OneApplicationResource]] OneApplicationResource -- applications/appId URI Handler

`OneApplicationResource` is a spark-api-AbstractApplicationResource.md[AbstractApplicationResource] (and so a spark-api-ApiRequestContext.md[ApiRequestContext] indirectly) that spark-api-ApiRootResource.md#applications_appId[ApiRootResource] uses to handle <<root, applications/appId>> URI path.

[[paths]]
.OneApplicationResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

| [[root]] `/`
| GET
| <<getApp, getApp>>
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

$ http http://localhost:4040/api/v1/applications/local-1528288219790
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 255
Content-Type: application/json
Date: Wed, 06 Jun 2018 12:41:43 GMT
Server: Jetty(9.3.z-SNAPSHOT)
Vary: Accept-Encoding, User-Agent

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
```

=== [[getApp]] `getApp` Method

[source, scala]
----
getApp(): ApplicationInfo
----

`getApp` requests the spark-api-ApiRequestContext.md#uiRoot[UIRoot] for the spark-api-UIRoot.md#getApplicationInfo[application info] (given the spark-api-BaseAppResource.md#appId[appId]).

In the end, `getApp` returns the `ApplicationInfo` if available or reports a `NotFoundException`:

```
unknown app: [appId]
```
