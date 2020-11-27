# Web UI &mdash; Spark Application's Web Console

**Web UI** (aka *Application UI* or *webUI* or *Spark UI*) is the web interface of a Spark application to monitor and inspect Spark jobs in a web browser.

![Welcome Page of web UI &mdash; Jobs Tab](../images/webui/spark-webui-jobs.png)

web UI is available at `http://[driverHostname]:4040` by default.

NOTE: The default port can be changed using spark-webui-properties.md#spark.ui.port[spark.ui.port] configuration property. `SparkContext` will increase the port if it is already taken until a free one is found.

web UI comes with the following tabs (_pages_):

. spark-webui-jobs.md[Jobs]
. spark-webui-stages.md[Stages]
. spark-webui-storage.md[Storage]
. spark-webui-environment.md[Environment]
. spark-webui-executors.md[Executors]

TIP: You can use the web UI after the application has finished by persisting events (using spark-history-server:EventLoggingListener.md[EventLoggingListener]) and using spark-history-server:index.md[Spark History Server].

NOTE: All the information that is displayed in web UI is available thanks to spark-webui-JobProgressListener.md[JobProgressListener] and other SparkListener.md[]s. One could say that web UI is a web layer over Spark listeners.
