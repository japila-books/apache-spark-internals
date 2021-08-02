# RestSubmissionServer

`RestSubmissionServer` is an [abstraction](#contract) of [Application Submission Gateways](#implementations) that can handle [submit](#submitRequestServlet), [kill](#killRequestServlet) and [status](#statusRequestServlet) requests using [REST API](#contextToServlet) (JSON over HTTP).

## <span id="contextToServlet"> URLs and RestServlets

URL | Method | RestServlet
----|--------|--
 /v1/submissions/create/* | POST  | [SubmitRequestServlet](#submitRequestServlet)
 /v1/submissions/kill/*   | POST  | [KillRequestServlet](#killRequestServlet)
 /v1/submissions/status/* | GET   | [StatusRequestServlet](#statusRequestServlet)
 /*                       | (all) | ErrorServlet

The above URLs and `RestServlet`s are registered when `RestSubmissionServer` is requested to [start](#start).

## Contract

### <span id="killRequestServlet"> killRequestServlet

```scala
killRequestServlet: KillRequestServlet
```

Used when:

* `RestSubmissionServer` is requested for the [contextToServlet](#contextToServlet)

### <span id="statusRequestServlet"> statusRequestServlet

```scala
statusRequestServlet: StatusRequestServlet
```

Used when:

* `RestSubmissionServer` is requested for the [contextToServlet](#contextToServlet)

### <span id="submitRequestServlet"> submitRequestServlet

```scala
submitRequestServlet: SubmitRequestServlet
```

Used when:

* `RestSubmissionServer` is requested for the [contextToServlet](#contextToServlet)

## Implementations

* MesosRestServer
* [StandaloneRestServer](StandaloneRestServer.md)

## Creating Instance

`RestSubmissionServer` takes the following to be created:

* <span id="host"> Host name
* <span id="requestedPort"> Requested Port
* <span id="masterConf"> [SparkConf](../SparkConf.md)

??? note "Abstract Class"
    `RestSubmissionServer` is an abstract class and cannot be created directly. It is created indirectly for the [concrete RestSubmissionServers](#implementations).

## <span id="start"> Starting

```scala
start(): Int
```

`start` [starts](#doStart) a REST service on the [requested port](#requestedPort) (or any free higher).

`start` prints out the following INFO to the logs:

```text
Started REST server for submitting applications on port [port]
```

In the end, `start` returns the port of the server.

`start` is used when:

* `Master` (Spark Standalone) is requested to [onStart](Master.md#onStart)

### <span id="doStart"> doStart

```scala
doStart(
  startPort: Int): (Server, Int)
```

`doStart`...FIXME

## Logging

`RestSubmissionServer` is an abstract class and logging is configured using the logger of the [implementations](#implementations).
