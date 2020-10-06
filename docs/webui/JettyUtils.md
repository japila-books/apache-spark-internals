== [[JettyUtils]] JettyUtils

`JettyUtils` is a set of <<utility-methods, utility methods>> for creating Jetty HTTP Server-specific components.

[[utility-methods]]
.JettyUtils's Utility Methods
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| <<createServlet, createServlet>>
| Creates an HttpServlet

| <<createStaticHandler, createStaticHandler>>
| Creates a Handler for a static content

| <<createServletHandler, createServletHandler>>
| Creates a ServletContextHandler for a path

| <<createRedirectHandler, createRedirectHandler>>
|
|===

=== [[createServletHandler]] Creating ServletContextHandler for Path -- `createServletHandler` Method

[source, scala]
----
createServletHandler(
  path: String,
  servlet: HttpServlet,
  basePath: String): ServletContextHandler
createServletHandler[T <: AnyRef](
  path: String,
  servletParams: ServletParams[T],
  securityMgr: SecurityManager,
  conf: SparkConf,
  basePath: String = ""): ServletContextHandler // <1>
----
<1> Uses the first three-argument `createServletHandler`

`createServletHandler`...FIXME

[NOTE]
====
`createServletHandler` is used when:

* `WebUI` is requested to spark-webui-WebUI.md#attachPage[attachPage]

* `MetricsServlet` is requested to `getHandlers`

* Spark Standalone's `WorkerWebUI` is requested to `initialize`
====

=== [[createServlet]] Creating HttpServlet -- `createServlet` Method

[source, scala]
----
createServlet[T <: AnyRef](
  servletParams: ServletParams[T],
  securityMgr: SecurityManager,
  conf: SparkConf): HttpServlet
----

`createServlet` creates the `X-Frame-Options` header that can be either `ALLOW-FROM` with the value of spark-webui-properties.md#spark.ui.allowFramingFrom[spark.ui.allowFramingFrom] configuration property if defined or `SAMEORIGIN`.

`createServlet` creates a Java Servlets `HttpServlet` with support for `GET` requests.

When handling `GET` requests, the `HttpServlet` first checks view permissions of the remote user (by requesting the `SecurityManager` to `checkUIViewPermissions` of the remote user).

[TIP]
====
Enable `DEBUG` logging level for `org.apache.spark.SecurityManager` logger to see what happens when `SecurityManager` does the security check.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.SecurityManager=DEBUG
```

You should see the following DEBUG message in the logs:

```
DEBUG SecurityManager: user=[user] aclsEnabled=[aclsEnabled] viewAcls=[viewAcls] viewAclsGroups=[viewAclsGroups]
```
====

With view permissions check passed, the `HttpServlet` sends a response with the following:

* FIXME

In case the view permissions didn't allow to view the page, the `HttpServlet` sends an error response with the following:

* Status `403`

* `Cache-Control` header with "no-cache, no-store, must-revalidate"

* Error message: "User is not authorized to access this page."

NOTE: `createServlet` is used exclusively when `JettyUtils` is requested to <<createServletHandler, createServletHandler>>.

=== [[createStaticHandler]] Creating Handler For Static Content -- `createStaticHandler` Method

[source, scala]
----
createStaticHandler(resourceBase: String, path: String): ServletContextHandler
----

`createStaticHandler` creates a handler for serving files from a static directory

Internally, `createStaticHandler` creates a Jetty `ServletContextHandler` and sets `org.eclipse.jetty.servlet.Default.gzip` init parameter to `false`.

`createRedirectHandler` creates a Jetty https://www.eclipse.org/jetty/javadoc/current/org/eclipse/jetty/servlet/DefaultServlet.html[DefaultServlet].

[NOTE]
====
Quoting the official documentation of Jetty's https://www.eclipse.org/jetty/javadoc/current/org/eclipse/jetty/servlet/DefaultServlet.html[DefaultServlet]:

> *DefaultServlet* The default servlet. This servlet, normally mapped to `/`, provides the handling for static content, OPTION and TRACE methods for the context. The following initParameters are supported, these can be set either on the servlet itself or as ServletContext initParameters with a prefix of `org.eclipse.jetty.servlet.Default.`

With that, `org.eclipse.jetty.servlet.Default.gzip` is to configure https://www.eclipse.org/jetty/documentation/current/advanced-extras.html#default-servlet-init[gzip] init parameter for Jetty's `DefaultServlet`.

> *gzip* If set to true, then static content will be served as gzip content encoded if a matching resource is found ending with ".gz" (default `false`) (deprecated: use precompressed)

====

`createRedirectHandler` resolves the `resourceBase` in the Spark classloader and, if successful, sets `resourceBase` init parameter of the Jetty `DefaultServlet` to the URL.

NOTE: https://www.eclipse.org/jetty/documentation/current/advanced-extras.html#default-servlet-init[resourceBase] init parameter is used to replace the context resource base.

`createRedirectHandler` requests the `ServletContextHandler` to use the `path` as the context path and register the `DefaultServlet` to serve it.

`createRedirectHandler` throws an `Exception` if the input `resourceBase` could not be resolved.

```
Could not find resource path for Web UI: [resourceBase]
```

NOTE: `createStaticHandler` is used when spark-webui-SparkUI.md#initialize[SparkUI], spark-history-server:HistoryServer.md#initialize[HistoryServer], Spark Standalone's `MasterWebUI` and `WorkerWebUI`, Spark on Mesos' `MesosClusterUI` are requested to initialize.

=== [[createRedirectHandler]] `createRedirectHandler` Method

[source, scala]
----
createRedirectHandler(
  srcPath: String,
  destPath: String,
  beforeRedirect: HttpServletRequest => Unit = x => (),
  basePath: String = "",
  httpMethods: Set[String] = Set("GET")): ServletContextHandler
----

`createRedirectHandler`...FIXME

NOTE: `createRedirectHandler` is used when spark-webui-SparkUI.md#initialize[SparkUI] and Spark Standalone's `MasterWebUI` are requested to initialize.
