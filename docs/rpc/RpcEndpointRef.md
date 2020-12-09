# RpcEndpointRef

`RpcEndpointRef` is a reference to a rpc:RpcEndpoint.md[RpcEndpoint] in a rpc:index.md[RpcEnv].

RpcEndpointRef is a serializable entity and so you can send it over a network or save it for later use (it can however be deserialized using the owning `RpcEnv` only).

A RpcEndpointRef has <<rpcaddress, an address>> (a Spark URL), and a name.

You can send asynchronous one-way messages to the corresponding RpcEndpoint using <<send, send>> method.

You can send a semi-synchronous message, i.e. "subscribe" to be notified when a response arrives, using `ask` method. You can also block the current calling thread for a response using `askWithRetry` method.

* `spark.rpc.numRetries` (default: `3`) - the number of times to retry connection attempts.
* `spark.rpc.retry.wait` (default: `3s`) - the number of milliseconds to wait on each retry.

It also uses rpc:index.md#endpoint-lookup-timeout[lookup timeouts].

== [[send]] send Method

CAUTION: FIXME

== [[askWithRetry]] askWithRetry Method

CAUTION: FIXME
