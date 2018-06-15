== [[UIUtils]] UIUtils

`UIUtils` is a utility object for...FIXME

=== [[headerSparkPage]] `headerSparkPage` Method

[source, scala]
----
headerSparkPage(
  request: HttpServletRequest,
  title: String,
  content: => Seq[Node],
  activeTab: SparkUITab,
  refreshInterval: Option[Int] = None,
  helpText: Option[String] = None,
  showVisualization: Boolean = false,
  useDataTables: Boolean = false): Seq[Node]
----

`headerSparkPage`...FIXME

NOTE: `headerSparkPage` is used when...FIXME
