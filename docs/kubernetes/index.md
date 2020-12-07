# Kebernetes

`Kebernetes` is among the cluster managers supported by Apache Spark (using [KubernetesClusterManager](KubernetesClusterManager.md)).

Apache Spark supports **k8s://**-prefixed master URLs.

## Minikube

Quoting the [official documentation]({{ spark.doc }}/running-on-kubernetes.html):

> Spark (starting with version 2.3) ships with a Dockerfile that can be used for this purpose, or customized to match an individual application’s needs. It can be found in the `kubernetes/dockerfiles/` directory.

### minikube start

```text
➜  ~ minikube start
😄  minikube v1.15.1 na Darwin 11.0.1
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🏃  Updating the running docker "minikube" container ...
🐳  Przygotowywanie Kubernetesa v1.19.4 na Docker 19.03.13...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```text
➜  ~ kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:32768
KubeDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

```text
➜  ~ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/jacek/.minikube/ca.crt
    server: https://127.0.0.1:32768
  name: minikube
contexts:
- context:
    cluster: minikube
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/jacek/.minikube/profiles/minikube/client.crt
    client-key: /Users/jacek/.minikube/profiles/minikube/client.key
```

### spark-shell

```text
K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}') \
./bin/spark-shell \
  --master k8s://$K8S_SERVER \
  --verbose
```

```text
20/12/07 11:02:25 ERROR Utils: Uncaught exception in thread kubernetes-executor-snapshots-subscribers-1
org.apache.spark.SparkException: Must specify the executor container image
	at org.apache.spark.deploy.k8s.features.BasicExecutorFeatureStep.$anonfun$executorContainerImage$1(BasicExecutorFeatureStep.scala:41)
	at scala.Option.getOrElse(Option.scala:189)
	at org.apache.spark.deploy.k8s.features.BasicExecutorFeatureStep.<init>(BasicExecutorFeatureStep.scala:41)
	at org.apache.spark.scheduler.cluster.k8s.KubernetesExecutorBuilder.buildFromFeatures(KubernetesExecutorBuilder.scala:43)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator.$anonfun$onNewSnapshots$16(ExecutorPodsAllocator.scala:216)
	at scala.collection.immutable.Range.foreach$mVc$sp(Range.scala:158)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator.onNewSnapshots(ExecutorPodsAllocator.scala:208)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator.$anonfun$start$1(ExecutorPodsAllocator.scala:82)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator.$anonfun$start$1$adapted(ExecutorPodsAllocator.scala:82)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsSnapshotsStoreImpl.$anonfun$callSubscriber$1(ExecutorPodsSnapshotsStoreImpl.scala:110)
	at org.apache.spark.util.Utils$.tryLogNonFatalError(Utils.scala:1357)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsSnapshotsStoreImpl.org$apache$spark$scheduler$cluster$k8s$ExecutorPodsSnapshotsStoreImpl$$callSubscriber(ExecutorPodsSnapshotsStoreImpl.scala:107)
	at org.apache.spark.scheduler.cluster.k8s.ExecutorPodsSnapshotsStoreImpl.$anonfun$addSubscriber$1(ExecutorPodsSnapshotsStoreImpl.scala:71)
	at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)
	at java.base/java.util.concurrent.FutureTask.runAndReset(FutureTask.java:305)
	at java.base/java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:305)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
	at java.base/java.lang.Thread.run(Thread.java:834)
```
