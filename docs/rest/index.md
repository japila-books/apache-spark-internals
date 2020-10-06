= Status REST API -- Monitoring Spark Applications Using REST API

*Status REST API* is a collection of REST endpoints under `/api/v1` URI path in the link:spark-api-UIRoot.adoc[root containers for application UI information]:

* [[SparkUI]] link:spark-webui-SparkUI.adoc[SparkUI] - Application UI for an active Spark application (i.e. a Spark application that is still running)

* [[HistoryServer]] xref:spark-history-server:HistoryServer.adoc[HistoryServer] - Application UI for active and completed Spark applications (i.e. Spark applications that are still running or have already finished)

Status REST API uses link:spark-api-ApiRootResource.adoc[ApiRootResource] main resource class that registers `/api/v1` URI <<paths, path and the subpaths>>.

[[paths]]
.URI Paths
[cols="1,2",options="header",width="100%"]
|===
| Path
| Description

| [[applications]] `applications`
| [[ApplicationListResource]] Delegates to the link:spark-api-ApplicationListResource.adoc[ApplicationListResource] resource class

| [[applications_appId]] `applications/\{appId}`
| [[OneApplicationResource]] Delegates to the link:spark-api-OneApplicationResource.adoc[OneApplicationResource] resource class

| [[version]] `version`
| Creates a `VersionInfo` with the current version of Spark
|===

Status REST API uses the following components:

* https://jersey.github.io/[Jersey RESTful Web Services framework] with support for the https://github.com/jax-rs[Java API for RESTful Web Services] (JAX-RS API)

* https://www.eclipse.org/jetty/[Eclipse Jetty] as the lightweight HTTP server and the https://jcp.org/en/jsr/detail?id=369[Java Servlet] container
