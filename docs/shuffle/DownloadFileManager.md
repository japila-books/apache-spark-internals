# DownloadFileManager

`DownloadFileManager` is an [abstraction](#contract) of [file managers](#implementations) that can [createTempFile](#createTempFile) and [registerTempFileToClean](#registerTempFileToClean).

## Contract

### <span id="createTempFile"> createTempFile

```java
DownloadFile createTempFile(
  TransportConf transportConf)
```

Used when:

* `DownloadCallback` (of [OneForOneBlockFetcher](../storage/OneForOneBlockFetcher.md)) is created

### <span id="registerTempFileToClean"> registerTempFileToClean

```java
boolean registerTempFileToClean(
  DownloadFile file)
```

Used when:

* `DownloadCallback` (of [OneForOneBlockFetcher](../storage/OneForOneBlockFetcher.md)) is requested to `onComplete`

## Implementations

* RemoteBlockDownloadFileManager
* [ShuffleBlockFetcherIterator](../storage/ShuffleBlockFetcherIterator.md)
