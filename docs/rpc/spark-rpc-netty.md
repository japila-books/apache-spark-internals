# Netty-Based RpcEnv

Netty-based RPC Environment is created by `NettyRpcEnvFactory` when rpc:index.md#settings[spark.rpc] is `netty` or `org.apache.spark.rpc.netty.NettyRpcEnvFactory`.

NettyRpcEnv is only started on spark-driver.md[the driver]. See <<client-mode, Client Mode>>.

The default port to listen to is `7077`.

When NettyRpcEnv starts, the following INFO message is printed out in the logs:

```
Successfully started service 'NettyRpcEnv' on port 0.
```

== [[thread-pools]] Thread Pools

=== shuffle-server-ID

`EventLoopGroup` uses a daemon thread pool called `shuffle-server-ID`, where `ID` is a unique integer for `NioEventLoopGroup` (`NIO`) or `EpollEventLoopGroup` (`EPOLL`) for the Shuffle server.

CAUTION: FIXME Review Netty's `NioEventLoopGroup`.

CAUTION: FIXME Where are `SO_BACKLOG`, `SO_RCVBUF`, `SO_SNDBUF` channel options used?

=== dispatcher-event-loop-ID

NettyRpcEnv's Dispatcher uses the daemon fixed thread pool with <<settings, spark.rpc.netty.dispatcher.numThreads>> threads.

Thread names are formatted as `dispatcher-event-loop-ID`, where `ID` is a unique, sequentially assigned integer.

It starts the message processing loop on all of the threads.

=== netty-rpc-env-timeout

NettyRpcEnv uses the daemon single-thread scheduled thread pool `netty-rpc-env-timeout`.

```
"netty-rpc-env-timeout" #87 daemon prio=5 os_prio=31 tid=0x00007f887775a000 nid=0xc503 waiting on condition [0x0000000123397000]
```

=== netty-rpc-connection-ID

NettyRpcEnv uses the daemon cached thread pool with up to <<settings, spark.rpc.connect.threads>> threads.

Thread names are formatted as `netty-rpc-connection-ID`, where `ID` is a unique, sequentially assigned integer.

== [[settings]] Settings

The Netty-based implementation uses the following properties:

* `spark.rpc.io.mode` (default: `NIO`) - `NIO` or `EPOLL` for low-level IO. `NIO` is always available, while `EPOLL` is only available on Linux. `NIO` uses `io.netty.channel.nio.NioEventLoopGroup` while `EPOLL` `io.netty.channel.epoll.EpollEventLoopGroup`.
* `spark.shuffle.io.numConnectionsPerPeer` always equals `1`
* `spark.rpc.io.threads` (default: `0`; maximum: `8`) - the number of threads to use for the Netty client and server thread pools.
** `spark.shuffle.io.serverThreads` (default: the value of `spark.rpc.io.threads`)
** `spark.shuffle.io.clientThreads` (default: the value of `spark.rpc.io.threads`)
* `spark.rpc.netty.dispatcher.numThreads` (default: the number of processors available to JVM)
* `spark.rpc.connect.threads` (default: `64`) - used in cluster mode to communicate with a remote RPC endpoint
* `spark.port.maxRetries` (default: `16` or `100` for testing when `spark.testing` is set) controls the maximum number of binding attempts/retries to a port before giving up.

== [[endpoints]] Endpoints

* `endpoint-verifier` (`RpcEndpointVerifier`) - a rpc:RpcEndpoint.md[RpcEndpoint] for remote RpcEnvs to query whether an RpcEndpoint exists or not. It uses `Dispatcher` that keeps track of registered endpoints and responds `true`/`false` to `CheckExistence` message.

`endpoint-verifier` is used to check out whether a given endpoint exists or not before the endpoint's reference is given back to clients.

One use case is when an spark-standalone.md#AppClient[AppClient connects to standalone Masters] before it registers the application it acts for.

CAUTION: FIXME Who'd like to use `endpoint-verifier` and how?

== Message Dispatcher

A message dispatcher is responsible for routing RPC messages to the appropriate endpoint(s).

It uses the daemon fixed thread pool `dispatcher-event-loop` with `spark.rpc.netty.dispatcher.numThreads` threads for dispatching messages.

```
"dispatcher-event-loop-0" #26 daemon prio=5 os_prio=31 tid=0x00007f8877153800 nid=0x7103 waiting on condition [0x000000011f78b000]
```
