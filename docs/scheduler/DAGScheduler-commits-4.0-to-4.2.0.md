---
title: DAGScheduler Commits
subtitle: v4.0.0..v4.2.0
---

# DAGScheduler Commits &mdash; v4.0.0..v4.2.0

This page is a list of [DAGScheduler.scala]({{ spark.github }}/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala) commits between Spark v4.0.0 and v4.2.0 with JIRA links, newest first.

Once reviewed, this page should be deleted.

| Hash | Date | JIRA | Subject |
|---|---|---|---|
| [c9e2d65176e]({{ spark.commit }}/c9e2d65176e) | 2026-04-30 | [SPARK-56575](https://issues.apache.org/jira/browse/SPARK-56575) | Extract scheduleResubmit() helper to remove identical code blocks |
| [34159e5a7bf]({{ spark.commit }}/34159e5a7bf) | 2026-04-28 | [SPARK-56509](https://issues.apache.org/jira/browse/SPARK-56509) | SparkSQL Last Attempt Metrics |
| [54294aef818]({{ spark.commit }}/54294aef818) | 2026-04-21 | [SPARK-56496](https://issues.apache.org/jira/browse/SPARK-56496) | Unify stage retry limit checks into canRetryStage helper in DAGScheduler |
| [5365b3f0e82]({{ spark.commit }}/5365b3f0e82) | 2026-04-20 | [SPARK-56499](https://issues.apache.org/jira/browse/SPARK-56499) | Deduplicate RDD graph BFS traversal pattern in DAGScheduler |
| [7e4a040e07c]({{ spark.commit }}/7e4a040e07c) | 2026-01-29 | [SPARK-55064](https://issues.apache.org/jira/browse/SPARK-55064) | Support query level indeterminate shuffle retry |
| [c6ca25a8028]({{ spark.commit }}/c6ca25a8028) | 2026-01-19 | [SPARK-54956](https://issues.apache.org/jira/browse/SPARK-54956) | Unify the indeterminate shuffle retry solution |
| [0da9e0505b5]({{ spark.commit }}/0da9e0505b5) | 2025-12-20 | [SPARK-54556](https://issues.apache.org/jira/browse/SPARK-54556) | Rollback succeeding shuffle map stages when shuffle checksum mismatch detected |
| [59fcc0f97bd]({{ spark.commit }}/59fcc0f97bd) | 2025-12-06 | — | Update DAGScheduler.scala |
| [9a37c3d59b8]({{ spark.commit }}/9a37c3d59b8) | 2025-11-11 | [SPARK-53898](https://issues.apache.org/jira/browse/SPARK-53898) | Fix race conditions between query cancellation and task completion triggered by eager shuffle cleanup |
| [26ba0ed11ed]({{ spark.commit }}/26ba0ed11ed) | 2025-10-09 | [SPARK-53564](https://issues.apache.org/jira/browse/SPARK-53564) | Avoid DAGScheduler exits due to blockManager RPC timeout in DAGSchedulerEventProcessLoop |
| [922adad1e3c]({{ spark.commit }}/922adad1e3c) | 2025-09-29 | [SPARK-53575](https://issues.apache.org/jira/browse/SPARK-53575) | Retry entire consumer stages when checksum mismatch detected for a retried shuffle map task |
| [dc46b147945]({{ spark.commit }}/dc46b147945) | 2025-08-06 | [SPARK-53064](https://issues.apache.org/jira/browse/SPARK-53064) | Rewrite MDC LogKey in Java |
| [7604f677d92]({{ spark.commit }}/7604f677d92) | 2025-05-19 | [SPARK-51272](https://issues.apache.org/jira/browse/SPARK-51272) | Aborting instead of continuing partially completed indeterminate result stage at ResubmitFailedStages |
