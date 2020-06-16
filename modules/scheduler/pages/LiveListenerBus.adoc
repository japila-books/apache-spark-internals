= LiveListenerBus

*LiveListenerBus* is an event bus to announce application-wide events in a Spark application. It asynchronously passes <<events, listener events>> to registered xref:ROOT:SparkListener.adoc[]s (based on xref:ROOT:configuration-properties.adoc#spark.extraListeners[spark.extraListeners] configuration property).

.LiveListenerBus, SparkListenerEvents, and Senders
image::spark-sparklistener-event-senders.png[align="center"]

LiveListenerBus is a single-JVM link:spark-SparkListenerBus.adoc[SparkListenerBus] that uses <<listenerThread, listenerThread to poll events>>. Emitters are supposed to use <<post, `post` method to post `SparkListenerEvent` events>>.

NOTE: The event queue is http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/LinkedBlockingQueue.html[java.util.concurrent.LinkedBlockingQueue] with capacity of 10000 `SparkListenerEvent` events.

== [[creating-instance]] Creating Instance

LiveListenerBus takes the following to be created:

* [[conf]] xref:ROOT:SparkConf.adoc[]

LiveListenerBus is created (and <<start, started>>) when SparkContext is requested to xref:ROOT:SparkContext.adoc#listenerBus[initialize].

== [[start]] Starting LiveListenerBus

[source, scala]
----
start(
  sc: SparkContext): Unit
----

`start` starts <<listenerThread, processing events>>.

Internally, it saves the input `SparkContext` for later use and starts <<listenerThread, listenerThread>>. It makes sure that it only happens when LiveListenerBus has not been started before (i.e. `started` is disabled).

If however LiveListenerBus has already been started, a `IllegalStateException` is thrown:

```
[name] already started!
```

== [[post]] Posting SparkListenerEvent Event

[source, scala]
----
post(
  event: SparkListenerEvent): Unit
----

`post` puts the input `event` onto the internal `eventQueue` queue and releases the internal `eventLock` semaphore. If the event placement was not successful (and it could happen since it is tapped at 10000 events) <<onDropEvent, onDropEvent>> method is called.

The event publishing is only possible when `stopped` flag has been enabled.

CAUTION: FIXME Who's enabling the `stopped` flag and when/why?

If LiveListenerBus has been stopped, the following ERROR appears in the logs:

```
[name] has already stopped! Dropping event [event]
```

== [[onDropEvent]] Event Dropped Callback

[source, scala]
----
onDropEvent(
  event: SparkListenerEvent): Unit
----

`onDropEvent` is called when no further events can be added to the internal `eventQueue` queue (while <<post, posting a SparkListenerEvent event>>).

It simply prints out the following ERROR message to the logs and ensures that it happens only once.

```
ERROR Dropping SparkListenerEvent because no remaining room in event queue. This likely means one of the SparkListeners is too slow and cannot keep up with the rate at which tasks are being started by the scheduler.
```

NOTE: It uses the internal `logDroppedEvent` atomic variable to track the state.

== [[stop]] Stopping LiveListenerBus

[source, scala]
----
stop(): Unit
----

`stop` releases the internal `eventLock` semaphore and waits until <<listenerThread, listenerThread>> dies. It can only happen after all events were posted (and polling `eventQueue` gives nothing).

It checks that `started` flag is enabled (i.e. `true`) and throws a `IllegalStateException` otherwise.

```
Attempted to stop [name] that has not yet started!
```

`stopped` flag is enabled.

== [[listenerThread]] listenerThread for Event Polling

LiveListenerBus uses xref:ROOT:spark-SparkListenerBus.adoc[] single-daemon thread that ensures that the polling events from the event queue is only after <<start, the listener was started>> and only one event at a time.

CAUTION: FIXME There is some logic around no events in the queue.

== [[addToStatusQueue]] Registering SparkListenerInterface with Application Status Queue

[source, scala]
----
addToStatusQueue(
  listener: SparkListenerInterface): Unit
----

addToStatusQueue simply <<addToQueue, adds the SparkListenerInterface>> to <<EVENT_LOG_QUEUE, eventLog>> queue.

addToStatusQueue is used when...FIXME

== [[addToQueue]] Registering SparkListenerInterface with Queue

[source, scala]
----
addToQueue(
  listener: SparkListenerInterface,
  queue: String): Unit
----

addToQueue...FIXME

addToQueue is used when...FIXME
