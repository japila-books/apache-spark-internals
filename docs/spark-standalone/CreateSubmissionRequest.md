# CreateSubmissionRequest

`CreateSubmissionRequest` is a `SubmitRestProtocolRequest`.

## Demo

Start `spark-shell` and use `:paste -raw` to paste the following snippet (in raw mode that allows bypassing `private[rest]` in the classes of our interest).

```text
package org.apache.spark.deploy.rest

object demo {
  def createCreateSubmissionRequest(): CreateSubmissionRequest = {
    val submitRequest = new CreateSubmissionRequest
    submitRequest.clientSparkVersion="3.1.2"
    submitRequest.sparkProperties=Map("spark.app.name" -> "DemoApp")
    submitRequest.appResource="hdfs://localhost:9000/demo-app-1.0.0-jar-with-dependencies.jar"
    submitRequest.appArgs="this is a demo".split("\\s+")
    submitRequest.environmentVariables=Map.empty
    submitRequest.validate
    submitRequest
  }

  def client(master: String = "spark://localhost:6066"): RestSubmissionClient = { // (1)
    new RestSubmissionClient(master)
  }
}
```

1. Uses the default `6066` REST port (not `7077`)

```scala
import org.apache.spark.deploy.rest.demo
val submitRequest = demo.createCreateSubmissionRequest
val client = demo.client()
```

```scala
client.createSubmission(submitRequest)
```

```text
scala> println(submitRequest.toJson)
{
  "action" : "CreateSubmissionRequest",
  "appArgs" : [ "this", "is", "a", "demo" ],
  "appResource" : "demo.jar",
  "clientSparkVersion" : "3.1.2",
  "environmentVariables" : { },
  "sparkProperties" : {
    "spark.app.name" : "DemoApp"
  }
}
```
