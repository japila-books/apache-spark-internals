---
tags:
  - DeveloperApi
---

# SparkListenerResourceProfileAdded

`SparkListenerResourceProfileAdded` is a [SparkListenerEvent](../SparkListenerEvent.md).

`SparkListenerResourceProfileAdded` can be intercepted using the following Spark listeners:

* `SparkFirehoseListener`
* [SparkListenerInterface](../SparkListenerInterface.md#onResourceProfileAdded)
* [SparkListener](../SparkListener.md#onResourceProfileAdded)

`SparkListenerResourceProfileAdded` is recorded using [AppStatusListener](../status/AppStatusListener.md#onResourceProfileAdded) for [status reporting and monitoring](../status/index.md).

## Creating Instance

`SparkListenerResourceProfileAdded` takes the following to be created:

* <span id="resourceProfile"> ResourceProfile

`SparkListenerResourceProfileAdded` is created when:

* `ResourceProfileManager` is requested to [register a new ResourceProfile](ResourceProfileManager.md#addResourceProfile)
* `JsonProtocol` ([Spark History Server](../history-server/index.md)) is requested to [resourceProfileAddedFromJson](../history-server/JsonProtocol.md#resourceProfileAddedFromJson)

## Spark History Server

`SparkListenerResourceProfileAdded` is logged in [Spark History Server](../history-server/index.md) using [EventLoggingListener](../history-server/EventLoggingListener.md#onResourceProfileAdded).

`SparkListenerResourceProfileAdded` is converted from and to JSON format using [JsonProtocol](../history-server/JsonProtocol.md) ([resourceProfileAddedFromJson](../history-server/JsonProtocol.md#resourceProfileAddedFromJson) and [resourceProfileAddedToJson](../history-server/JsonProtocol.md#resourceProfileAddedToJson), respectively).
