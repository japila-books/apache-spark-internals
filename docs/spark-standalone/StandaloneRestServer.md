# StandaloneRestServer

`StandaloneRestServer` is a [RestSubmissionServer](RestSubmissionServer.md).

## Creating Instance

`StandaloneRestServer` takes the following to be created:

* <span id="host"> Host Name
* <span id="requestedPort"> Requested Port
* <span id="masterConf"> [SparkConf](../SparkConf.md)
* <span id="masterEndpoint"> [RpcEndpointRef](../rpc/RpcEndpointRef.md) of the [Master](Master.md)
* <span id="masterUrl"> URL of the [Master](Master.md#masterUrl)

`StandaloneRestServer` is created when:

* `Master` is requested to [onStart](Master.md#onStart) (with [spark.master.rest.enabled](configuration-properties.md#spark.master.rest.enabled) configuration property enabled)

## <span id="submitRequestServlet"><span id="StandaloneSubmitRequestServlet"> StandaloneSubmitRequestServlet

`StandaloneRestServer` uses a `StandaloneSubmitRequestServlet` as the [submitRequestServlet](RestSubmissionServer.md#submitRequestServlet).

`StandaloneSubmitRequestServlet` requires the following parameters:

* `appResource` (the jar of a Spark application)
* `mainClass`
