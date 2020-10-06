== [[UIRootFromServletContext]] UIRootFromServletContext

`UIRootFromServletContext` manages the current <<attribute, UIRoot>> object in a Jetty `ContextHandler`.

[[attribute]]
`UIRootFromServletContext` uses its canonical name for the context attribute that is used to <<setUiRoot, set>> or <<getUiRoot, get>> the current spark-api-UIRoot.md[UIRoot] object (in Jetty's `ContextHandler`).

NOTE: https://www.eclipse.org/jetty/javadoc/current/org/eclipse/jetty/server/handler/ContextHandler.html[ContextHandler] is the environment for multiple Jetty `Handlers`, e.g. URI context path, class loader, static resource base.

In essence, `UIRootFromServletContext` is simply a "bridge" between two worlds, Spark's spark-api-UIRoot.md[UIRoot] and Jetty's `ContextHandler`.

=== [[setUiRoot]] `setUiRoot` Method

[source, scala]
----
setUiRoot(contextHandler: ContextHandler, uiRoot: UIRoot): Unit
----

`setUiRoot`...FIXME

NOTE: `setUiRoot` is used exclusively when `ApiRootResource` is requested to spark-api-ApiRootResource.md#getServletHandler[register /api/* context handler].

=== [[getUiRoot]] `getUiRoot` Method

[source, scala]
----
getUiRoot(context: ServletContext): UIRoot
----

`getUiRoot`...FIXME

NOTE: `getUiRoot` is used exclusively when `ApiRequestContext` is requested for the current spark-api-ApiRequestContext.md#uiRoot[UIRoot].
