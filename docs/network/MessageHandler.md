= MessageHandler

*MessageHandler* is a <<contract, contract>> of <<implementations, message handlers>> that can <<handle, handle>> messages.

[[contract]]
[source, java]
----
package org.apache.spark.network.server;

abstract class MessageHandler<T extends Message> {
  abstract void handle(T message) throws Exception;
  abstract void channelActive();
  abstract void exceptionCaught(Throwable cause);
  abstract void channelInactive();
}
----

.MessageHandler Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `handle`
| [[handle]] Used when...FIXME

| `channelActive`
| [[channelActive]] Used when...FIXME

| `exceptionCaught`
| [[exceptionCaught]] Used when...FIXME

| `channelInactive`
| [[channelInactive]] Used when...FIXME
|===

== [[implementations]] MessageHandlers

[cols="30m,70",options="header",width="100%"]
|===
| MessageHandler
| Description

| network:TransportRequestHandler.md[]
| [[TransportRequestHandler]]

| TransportResponseHandler
| [[TransportResponseHandler]]
|===
