== [[ApiRootResource]] ApiRootResource -- /api/v1 URI Handler

`ApiRootResource` is the spark-api-ApiRequestContext.md[ApiRequestContext] for the `/v1` URI path.

`ApiRootResource` uses `@Path("/v1")` annotation at the class level. It is a partial URI path template relative to the base URI of the server on which the resource is deployed, the context root of the application, and the URL pattern to which the JAX-RS runtime responds.

TIP: Learn more about `@Path` annotation in https://docs.oracle.com/cd/E19798-01/821-1841/6nmq2cp26/index.html[The @Path Annotation and URI Path Templates].

`ApiRootResource` <<getServletHandler, registers>> the `/api/*` context handler (with the REST resources and providers in `org.apache.spark.status.api.v1` package).

With the `@Path("/v1")` annotation and after <<getServletHandler, registering>> the `/api/*` context handler, `ApiRootResource` serves HTTP requests for <<paths, paths>> under the `/api/v1` URI paths for spark-webui-SparkUI.md#initialize[SparkUI] and spark-history-server:HistoryServer.md#initialize[HistoryServer].

`ApiRootResource` gives the metrics of a Spark application in JSON format (using JAX-RS API).

```
// start spark-shell
$ http http://localhost:4040/api/v1/applications
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 257
Content-Type: application/json
Date: Tue, 05 Jun 2018 18:36:16 GMT
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

// Fixed in Spark 2.3.1
// https://issues.apache.org/jira/browse/SPARK-24188
$ http http://localhost:4040/api/v1/version
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 43
Content-Type: application/json
Date: Thu, 14 Jun 2018 08:19:06 GMT
Server: Jetty(9.3.z-SNAPSHOT)
Vary: Accept-Encoding, User-Agent

{
    "spark": "2.3.1"
}
```

[[paths]]
.ApiRootResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

| [[applications]] `applications`
|
| [[ApplicationListResource]] Delegates to the spark-api-ApplicationListResource.md[ApplicationListResource] resource class

| [[applications_appId]] `applications/\{appId}`
|
| [[OneApplicationResource]] Delegates to the spark-api-OneApplicationResource.md[OneApplicationResource] resource class

| [[version]] `version`
| GET
| Creates a `VersionInfo` with the current version of Spark
|===

=== [[getServletHandler]] Creating /api/* Context Handler -- `getServletHandler` Method

[source, scala]
----
getServletHandler(uiRoot: UIRoot): ServletContextHandler
----

`getServletHandler` creates a Jetty `ServletContextHandler` for `/api` context path.

NOTE: The Jetty `ServletContextHandler` created does not support HTTP sessions as REST API is stateless.

`getServletHandler` creates a Jetty `ServletHolder` with the resources and providers in `org.apache.spark.status.api.v1` package. It then registers the `ServletHolder` to serve `/*` context path (under the `ServletContextHandler` for `/api`).

`getServletHandler` requests `UIRootFromServletContext` to spark-api-UIRootFromServletContext.md#setUiRoot[setUiRoot] with the `ServletContextHandler` and the input spark-api-UIRoot.md[UIRoot].

NOTE: `getServletHandler` is used when spark-webui-SparkUI.md#initialize[SparkUI] and spark-history-server:HistoryServer.md#initialize[HistoryServer] are requested to initialize.
