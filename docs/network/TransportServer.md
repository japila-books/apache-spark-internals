# TransportServer

== [[creating-instance]] Creating TransportServer Instance

TransportServer takes the following when created:

* [[context]] network:TransportContext.md[]
* [[hostToBind]] Host name to bind to
* [[portToBind]] Port number to bind to
* [[appRpcHandler]] network:RpcHandler.md[]
* [[bootstraps]] `TransportServerBootstraps`

When created, TransportServer <<init, init>> with the <<hostToBind, host>> and <<portToBind, port>> to bind to.

TransportServer is created when TransportContext is requested to network:TransportContext.md#createServer[create a server].

== [[init]] `init` Internal Method

[source, java]
----
void init(String hostToBind, int portToBind)
----

`init`...FIXME

NOTE: `init` is used exclusively when TransportServer is <<creating-instance, created>>.

== [[getPort]] `getPort` Method

[source, java]
----
int getPort()
----

`getPort`...FIXME

[NOTE]
====
`getPort` is used when:

* `NettyRpcEnv` is requested for the `address`

* Spark on YARN's `YarnShuffleService` is requested to `serviceInit`
====
