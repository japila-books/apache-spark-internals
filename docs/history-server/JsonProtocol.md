= JsonProtocol Utility
:navtitle: JsonProtocol

JsonProtocol is an utility to convert SparkListenerEvents <<sparkEventToJson, to>> and <<sparkEventFromJson, from>> JSON format.

JsonProtocol is used by xref:spark-history-server:EventLoggingListener.adoc[] and xref:spark-history-server:ReplayListenerBus.adoc[] (to xref:spark-history-server:EventLoggingListener.adoc#logEvent[log] and xref:spark-history-server:ReplayListenerBus.adoc#replay[replay] events for xref:spark-history-server:index.adoc[], respectively).

== [[sparkEventFromJson]] sparkEventFromJson Utility

[source,scala]
----
sparkEventFromJson(
  json: JValue): SparkListenerEvent
----

sparkEventFromJson...FIXME

sparkEventFromJson is used when ReplayListenerBus is requested to xref:spark-history-server:ReplayListenerBus.adoc#replay[replay].

== [[logStartToJson]] logStartToJson Utility

[source,scala]
----
logStartToJson(
  logStart: SparkListenerLogStart): JValue
----

logStartToJson...FIXME

logStartToJson is used when...FIXME

== [[taskEndFromJson]] taskEndFromJson Utility

[source,scala]
----
taskEndFromJson(
  json: JValue): SparkListenerTaskEnd
----

taskEndFromJson...FIXME

taskEndFromJson is used when JsonProtocol utility is used to <<sparkEventFromJson, sparkEventFromJson>>.

== [[executorMetricsUpdateFromJson]] executorMetricsUpdateFromJson Utility

[source,scala]
----
executorMetricsUpdateFromJson(
  json: JValue): SparkListenerExecutorMetricsUpdate
----

executorMetricsUpdateFromJson...FIXME

executorMetricsUpdateFromJson is used when JsonProtocol utility is used to <<sparkEventFromJson, sparkEventFromJson>>.

== [[taskEndReasonFromJson]] taskEndReasonFromJson Utility

[source,scala]
----
taskEndReasonFromJson(
  json: JValue): TaskEndReason
----

taskEndReasonFromJson...FIXME

taskEndReasonFromJson is used when JsonProtocol utility is used to <<taskEndFromJson, taskEndFromJson>>.

== [[stageInfoFromJson]] stageInfoFromJson Utility

[source,scala]
----
stageInfoFromJson(
  json: JValue): StageInfo
----

stageInfoFromJson...FIXME

stageInfoFromJson is used when JsonProtocol utility is used to <<jobStartFromJson, jobStartFromJson>>, <<stageSubmittedFromJson, stageSubmittedFromJson>>, <<stageCompletedFromJson, stageCompletedFromJson>>.

== [[taskInfoFromJson]] taskInfoFromJson Utility

[source,scala]
----
taskInfoFromJson(
  json: JValue): TaskInfo
----

taskInfoFromJson...FIXME

taskInfoFromJson is used when JsonProtocol utility is used to <<taskStartFromJson, taskStartFromJson>>, <<taskGettingResultFromJson, taskGettingResultFromJson>>, <<taskEndFromJson, taskEndFromJson>>.

== [[accumulableInfoFromJson]] accumulableInfoFromJson Utility

[source,scala]
----
accumulableInfoFromJson(
  json: JValue): AccumulableInfo
----

accumulableInfoFromJson...FIXME

accumulableInfoFromJson is used when JsonProtocol utility is used to <<taskEndReasonFromJson, taskEndReasonFromJson>>, <<executorMetricsUpdateFromJson, executorMetricsUpdateFromJson>>, <<stageInfoFromJson, stageInfoFromJson>>, <<taskInfoFromJson, taskInfoFromJson>>.

== [[accumValueFromJson]] accumValueFromJson Utility

[source,scala]
----
accumValueFromJson(
  name: Option[String],
  value: JValue): Any
----

accumValueFromJson...FIXME

accumValueFromJson is used when JsonProtocol utility is used to <<accumulableInfoFromJson, accumulableInfoFromJson>>.

== [[taskMetricsFromJson]] taskMetricsFromJson Utility

[source,scala]
----
taskMetricsFromJson(
  json: JValue): TaskMetrics
----

taskMetricsFromJson...FIXME

taskMetricsFromJson is used when JsonProtocol utility is used to <<taskEndFromJson, taskEndFromJson>> and <<taskEndReasonFromJson, taskEndReasonFromJson>>.

== [[taskEndToJson]] taskEndToJson Utility

[source,scala]
----
taskEndToJson(
  taskEnd: SparkListenerTaskEnd): JValue
----

taskEndToJson...FIXME

taskEndToJson is used when JsonProtocol utility is used to <<sparkEventToJson, convert a SparkListenerEvent to JSON>> (_serialize a SparkListenerEvent to JSON_).

== [[taskMetricsToJson]] taskMetricsToJson Utility

[source,scala]
----
taskMetricsToJson(
  taskMetrics: TaskMetrics): JValue
----

taskMetricsToJson...FIXME

taskMetricsToJson is used when JsonProtocol utility is used to <<taskEndToJson, taskEndToJson>>.

== [[blockUpdateFromJson]] blockUpdateFromJson Utility

[source,scala]
----
blockUpdateFromJson(
  json: JValue): SparkListenerBlockUpdated
----

blockUpdateFromJson...FIXME

blockUpdateFromJson is used when JsonProtocol utility is used to <<sparkEventFromJson, sparkEventFromJson>>.

== [[blockUpdatedInfoFromJson]] blockUpdatedInfoFromJson Utility

[source,scala]
----
blockUpdatedInfoFromJson(
  json: JValue): BlockUpdatedInfo
----

blockUpdatedInfoFromJson...FIXME

blockUpdatedInfoFromJson is used when JsonProtocol utility is used to <<blockUpdateFromJson, blockUpdateFromJson>>.
