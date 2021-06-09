# WebUIPage

`WebUIPage` is an [abstraction](#contract) of [pages](#implementations) (of a [WebUI](WebUI.md)) that can be rendered to [HTML](#render) and [JSON](#renderJson).

## Contract

### <span id="render"> Rendering Page (to HTML)

```scala
render(
  request: HttpServletRequest): Seq[Node]
```

Used when:

* `WebUI` is requested to [attach a page](WebUI.md#attachPage) (to handle the [URL](#prefix))

## Implementations

* AllExecutionsPage
* [AllJobsPage](AllJobsPage.md)
* [AllStagesPage](AllStagesPage.md)
* ApplicationPage
* BatchPage
* DriverPage
* [EnvironmentPage](EnvironmentPage.md)
* ExecutionPage
* [ExecutorsPage](ExecutorsPage.md)
* [ExecutorThreadDumpPage](ExecutorThreadDumpPage.md)
* HistoryPage
* [JobPage](JobPage.md)
* LogPage
* MasterPage
* MesosClusterPage
* [PoolPage](PoolPage.md)
* [RDDPage](RDDPage.md)
* [StagePage](StagePage.md)
* [StoragePage](StoragePage.md)
* StreamingPage
* StreamingQueryPage
* StreamingQueryStatisticsPage
* ThriftServerPage
* ThriftServerSessionPage
* WorkerPage

## Creating Instance

`WebUIPage` takes the following to be created:

* <span id="prefix"> URL Prefix

??? note "Abstract Class"
    `WebUIPage` is an abstract class and cannot be created directly. It is created indirectly for the [concrete WebUIPages](#implementations).

## <span id="renderJson"> Rendering Page to JSON

```scala
renderJson(
  request: HttpServletRequest): JValue
```

`renderJson` returns a `JNothing` by default.

`renderJson` is used when:

* `WebUI` is requested to [attach a page](WebUI.md#attachPage) (and handle the `/json` URL)
