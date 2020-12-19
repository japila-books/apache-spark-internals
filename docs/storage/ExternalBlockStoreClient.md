# ExternalBlockStoreClient

`ExternalBlockStoreClient` is a [BlockStoreClient](BlockStoreClient.md) that the driver and executors use when [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property is enabled.

## Creating Instance

`ExternalBlockStoreClient` takes the following to be created:

* <span id="conf"> [TransportConf](../network/TransportConf.md)
* <span id="secretKeyHolder"> `SecretKeyHolder`
* <span id="authEnabled"> `authEnabled` flag
* <span id="registrationTimeoutMs"> `registrationTimeoutMs`

`ExternalBlockStoreClient` is created when:

* `SparkEnv` utility is requested to [create a SparkEnv](../SparkEnv.md#create) (for the driver and executors) with [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property enabled
