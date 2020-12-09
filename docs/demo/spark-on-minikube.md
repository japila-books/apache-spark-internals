# Demo: Spark on Minikube

This demo shows how to run Spark applications on [Kubernetes](../kubernetes/index.md) (using [minikube](https://minikube.sigs.k8s.io/docs/)).

## Minikube

Quoting the [official documentation]({{ spark.doc }}/running-on-kubernetes.html):

> Spark (starting with version 2.3) ships with a Dockerfile that can be used for this purpose, or customized to match an individual application’s needs. It can be found in the `kubernetes/dockerfiles/` directory.

## minikube start

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

## Building Spark Images

Go to `kubernetes/dockerfiles/spark` (in your Spark installation) or `resource-managers/kubernetes/docker` (in the Spark source code).

```text
cd $SPARK_HOME
```

Note `-m` option to use minikube's Docker daemon.

```text
$ ./bin/docker-image-tool.sh -m -t spark-jacek-testing build
...
Successfully tagged spark:spark-jacek-testing
```

Point the shell to minikube's Docker daemon.

```text
eval $(minikube -p minikube docker-env)
```

List available images.

```text
$ docker images
REPOSITORY                                TAG                   IMAGE ID            CREATED             SIZE
spark                                     spark-jacek-testing   3de7715909ff        5 minutes ago       494MB
openjdk                                   8-jre-slim            8c3c0e49c694        2 weeks ago         187MB
k8s.gcr.io/kube-proxy                     v1.19.4               635b36f4d89f        3 weeks ago         118MB
k8s.gcr.io/kube-apiserver                 v1.19.4               b15c6247777d        3 weeks ago         119MB
k8s.gcr.io/kube-controller-manager        v1.19.4               4830ab618586        3 weeks ago         111MB
k8s.gcr.io/kube-scheduler                 v1.19.4               14cd22f7abe7        3 weeks ago         45.7MB
gcr.io/k8s-minikube/storage-provisioner   v3                    bad58561c4be        3 months ago        29.7MB
k8s.gcr.io/etcd                           3.4.13-0              0369cf4303ff        3 months ago        253MB
kubernetesui/dashboard                    v2.0.3                503bc4b7440b        5 months ago        225MB
k8s.gcr.io/coredns                        1.7.0                 bfe3a36ebd25        5 months ago        45.2MB
kubernetesui/metrics-scraper              v1.0.4                86262685d9ab        8 months ago        36.9MB
k8s.gcr.io/pause                          3.2                   80d28bedfe5d        9 months ago        683kB
```

## spark-shell

```text
cd $SPARK_HOME
```

```text
K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}') \
./bin/spark-shell \
  --master k8s://$K8S_SERVER \
  --deploy-mode client \
  --conf spark.kubernetes.container.image=spark:spark-jacek-testing \
  --verbose
```

```text
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Starting watch for pods with labels spark-app-selector=spark-application-1607344289149, spark-role=executor.
20/12/07 13:31:29 DEBUG ExecutorPodsAllocator: Pod allocation status: 0 running, 0 pending, 0 unacknowledged.
20/12/07 13:31:29 INFO ExecutorPodsAllocator: Going to request 2 executors from Kubernetes.
20/12/07 13:31:29 DEBUG ExecutorPodsPollingSnapshotSource: Starting to check for executor pod state every 30000 ms.
20/12/07 13:31:29 DEBUG ExecutorPodsAllocator: Requested executor with id 1 from Kubernetes.
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-1, action ADDED
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-1, action MODIFIED
20/12/07 13:31:29 DEBUG ExecutorPodsAllocator: Requested executor with id 2 from Kubernetes.
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-1, action MODIFIED
20/12/07 13:31:29 DEBUG ExecutorPodsAllocator: Still waiting for 2 executors before requesting more.
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-2, action ADDED
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-2, action MODIFIED
20/12/07 13:31:29 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-2, action MODIFIED
20/12/07 13:31:30 DEBUG ExecutorPodsAllocator: Pod allocation status: 0 running, 2 pending, 0 unacknowledged.
20/12/07 13:31:30 DEBUG ExecutorPodsAllocator: Still waiting for 2 executors before requesting more.
20/12/07 13:31:31 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-2, action MODIFIED
20/12/07 13:31:31 DEBUG ExecutorPodsWatchSnapshotSource: Received executor pod update for pod named spark-shell-9f169f763d2f737f-exec-1, action MODIFIED
20/12/07 13:31:32 DEBUG ExecutorPodsAllocator: Pod allocation status: 2 running, 0 pending, 0 unacknowledged.
20/12/07 13:31:32 DEBUG ExecutorPodsAllocator: Current number of running executors is equal to the number of requested executors. Not scaling up further.
20/12/07 13:31:37 INFO KubernetesClusterSchedulerBackend$KubernetesDriverEndpoint: Registered executor NettyRpcEndpointRef(spark-client://Executor) (192.168.68.105:54603) with ID 1
20/12/07 13:31:37 INFO KubernetesClusterSchedulerBackend$KubernetesDriverEndpoint: Registered executor NettyRpcEndpointRef(spark-client://Executor) (192.168.68.105:54604) with ID 2
20/12/07 13:31:37 INFO KubernetesClusterSchedulerBackend: SchedulerBackend is ready for scheduling beginning after reached minRegisteredResourcesRatio: 0.8
Spark context Web UI available at http://192.168.68.105:4040
Spark context available as 'sc' (master = k8s://https://127.0.0.1:32768, app id = spark-application-1607344289149).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.0.1
      /_/

Using Scala version 2.12.10 (OpenJDK 64-Bit Server VM, Java 11.0.9)
Type in expressions to have them evaluated.
Type :help for more information.

scala> spark.version
res0: String = 3.0.1

scala> sc.master
res1: String = k8s://https://127.0.0.1:32768
```
