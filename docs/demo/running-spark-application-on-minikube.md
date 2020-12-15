# Demo: Running Spark Application on minikube

This demo shows how to run a Spark application on [Kubernetes](../kubernetes/index.md) (using [minikube](https://minikube.sigs.k8s.io/docs/)).

!!! tip
    Review [Demo: spark-shell on minikube](spark-shell-on-minikube.md).

## Start minikube Cluster

Quoting [Prerequisites](http://spark.apache.org/docs/latest/running-on-kubernetes.html#prerequisites):

> We recommend 3 CPUs and 4g of memory to be able to start a simple Spark application with a single executor.

Let's start minikube with enough resources.

```text
$ minikube start --cpus 4 --memory 8192
😄  minikube v1.15.1 na Darwin 11.0.1
✨  Automatically selected the docker driver
👍  Starting control plane node minikube in cluster minikube
🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
🐳  Przygotowywanie Kubernetesa v1.19.4 na Docker 19.03.13...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```text
$ kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:55000
KubeDNS is running at https://127.0.0.1:55000/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

```text
$ kubectl get po -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-98x29            1/1     Running   0          20s
kube-system   etcd-minikube                      0/1     Running   0          26s
kube-system   kube-apiserver-minikube            1/1     Running   0          26s
kube-system   kube-controller-manager-minikube   0/1     Running   0          26s
kube-system   kube-proxy-vvgsp                   1/1     Running   0          20s
kube-system   kube-scheduler-minikube            0/1     Running   0          26s
kube-system   storage-provisioner                1/1     Running   0          26s
```

## Building Spark Image

```text
cd $SPARK_HOME
```

Go to `kubernetes/dockerfiles/spark` (in your Spark installation) or `resource-managers/kubernetes/docker` (in the Spark source code).

Note `-m` option to use minikube's Docker daemon.

```text
$ ./bin/docker-image-tool.sh \
    -b java_image_tag=11-jre-slim \
    -m \
    -t v3.0.1-demo \
    build
...
Successfully tagged spark:v3.0.1-demo
```

List available images.

```text
$ docker images
REPOSITORY                                TAG           IMAGE ID       CREATED          SIZE
spark                                     v3.0.1-demo   63bcb1380c7f   17 seconds ago   504MB
openjdk                                   11-jre-slim   57a8cfbe60f3   3 days ago       205MB
k8s.gcr.io/kube-proxy                     v1.19.4       635b36f4d89f   4 weeks ago      118MB
k8s.gcr.io/kube-controller-manager        v1.19.4       4830ab618586   4 weeks ago      111MB
k8s.gcr.io/kube-apiserver                 v1.19.4       b15c6247777d   4 weeks ago      119MB
k8s.gcr.io/kube-scheduler                 v1.19.4       14cd22f7abe7   4 weeks ago      45.7MB
gcr.io/k8s-minikube/storage-provisioner   v3            bad58561c4be   3 months ago     29.7MB
k8s.gcr.io/etcd                           3.4.13-0      0369cf4303ff   3 months ago     253MB
kubernetesui/dashboard                    v2.0.3        503bc4b7440b   5 months ago     225MB
k8s.gcr.io/coredns                        1.7.0         bfe3a36ebd25   5 months ago     45.2MB
kubernetesui/metrics-scraper              v1.0.4        86262685d9ab   8 months ago     36.9MB
k8s.gcr.io/pause                          3.2           80d28bedfe5d   10 months ago    683kB
```

## Building Spark Application Image

Point the shell to minikube's Docker daemon.

```text
eval $(minikube -p minikube docker-env)
```

Note that the image the Spark application project's image extends from (using `FROM` command) should be `spark:v3.0.1-demo` as follows:

```text
FROM spark:v3.0.1-demo
```

In your Spark application project execute the command to build and push a Docker image to minikube's Docker repository.

```text
sbt clean docker:publishLocal
```

## Creating Namespace

```text
kubectl create namespace spark-demo
```

## Create Service Account

!!! tip
    Learn more from the [Spark official documentation](http://spark.apache.org/docs/latest/running-on-kubernetes.html#rbac).

Without this step you could face the following exception message:

```text
Forbidden!Configured service account doesn't have access. Service account may have been revoked.
```

Create a service account `spark` in the `spark-demo` namespace.

```text
kubectl --namespace=spark-demo create serviceaccount spark
```

Create a cluster role binding `spark-role`.

```text
kubectl --namespace=spark-demo create clusterrolebinding spark-role \
  --clusterrole=edit \
  --serviceaccount=spark-demo:spark
```

## Submitting Spark Application to minikube

```text
cd $SPARK_HOME
```

```text
K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
```

```text
./bin/spark-submit \
  --master k8s://$K8S_SERVER \
  --deploy-mode cluster \
  --name spark-docker-example \
  --class meetup.SparkApp \
  --conf spark.kubernetes.container.image=spark-docker-example:0.1.0 \
  --conf spark.kubernetes.context=minikube \
  --conf spark.kubernetes.namespace=spark-demo \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --verbose \
  local:///opt/docker/lib/meetup.spark-docker-example-0.1.0.jar
```

After a few seconds, you should see the following messages:

```text
20/12/14 18:34:59 INFO LoggingPodStatusWatcherImpl: Application status for spark-b1f8840227074b62996f66b915044ee6 (phase: Pending)
20/12/14 18:34:59 INFO LoggingPodStatusWatcherImpl: State changed, new state:
	 pod name: spark-docker-example-3c07aa766251ce43-driver
	 namespace: spark-demo
	 labels: spark-app-selector -> spark-b1f8840227074b62996f66b915044ee6, spark-role -> driver
	 pod uid: a8c06d26-ad8a-4b78-96e1-3e0be00a4da8
	 creation time: 2020-12-14T17:34:58Z
	 service account name: spark
	 volumes: spark-local-dir-1, spark-conf-volume, spark-token-tsd97
	 node name: minikube
	 start time: 2020-12-14T17:34:58Z
	 phase: Running
	 container status:
		 container name: spark-kubernetes-driver
		 container image: spark-docker-example:0.1.0
		 container state: running
		 container started at: 2020-12-14T17:34:59Z
20/12/14 18:35:00 INFO LoggingPodStatusWatcherImpl: Application status for spark-b1f8840227074b62996f66b915044ee6 (phase: Running)
```

And then...

```text
20/12/14 18:35:06 INFO LoggingPodStatusWatcherImpl: State changed, new state:
	 pod name: spark-docker-example-3c07aa766251ce43-driver
	 namespace: spark-demo
	 labels: spark-app-selector -> spark-b1f8840227074b62996f66b915044ee6, spark-role -> driver
	 pod uid: a8c06d26-ad8a-4b78-96e1-3e0be00a4da8
	 creation time: 2020-12-14T17:34:58Z
	 service account name: spark
	 volumes: spark-local-dir-1, spark-conf-volume, spark-token-tsd97
	 node name: minikube
	 start time: 2020-12-14T17:34:58Z
	 phase: Succeeded
	 container status:
		 container name: spark-kubernetes-driver
		 container image: spark-docker-example:0.1.0
		 container state: terminated
		 container started at: 2020-12-14T17:34:59Z
		 container finished at: 2020-12-14T17:35:05Z
		 exit code: 0
		 termination reason: Completed
20/12/14 18:35:06 INFO LoggingPodStatusWatcherImpl: Application status for spark-b1f8840227074b62996f66b915044ee6 (phase: Succeeded)
20/12/14 18:35:06 INFO LoggingPodStatusWatcherImpl: Container final statuses:


	 container name: spark-kubernetes-driver
	 container image: spark-docker-example:0.1.0
	 container state: terminated
	 container started at: 2020-12-14T17:34:59Z
	 container finished at: 2020-12-14T17:35:05Z
	 exit code: 0
	 termination reason: Completed
```

## Spark Application Management

```text
K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
```

```text
$ ./bin/spark-submit --status "spark-demo:spark-docker-example-*" --master k8s://$K8S_SERVER
...
Application status (driver):
	 pod name: spark-docker-example-3c07aa766251ce43-driver
	 namespace: spark-demo
	 labels: spark-app-selector -> spark-b1f8840227074b62996f66b915044ee6, spark-role -> driver
	 pod uid: a8c06d26-ad8a-4b78-96e1-3e0be00a4da8
	 creation time: 2020-12-14T17:34:58Z
	 service account name: spark
	 volumes: spark-local-dir-1, spark-conf-volume, spark-token-tsd97
	 node name: minikube
	 start time: 2020-12-14T17:34:58Z
	 phase: Succeeded
	 container status:
		 container name: spark-kubernetes-driver
		 container image: spark-docker-example:0.1.0
		 container state: terminated
		 container started at: 2020-12-14T17:34:59Z
		 container finished at: 2020-12-14T17:35:05Z
		 exit code: 0
		 termination reason: Completed
```

## Listing Services

```text
$ kubectl --namespace=spark-demo get services
NAME                                               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
spark-docker-example-3c07aa766251ce43-driver-svc   ClusterIP   None         <none>        7078/TCP,7079/TCP,4040/TCP   2m55s
```

## Accessing web UI

Find the driver pod.

```text
kubectl --namespace=spark-demo get pod
```

```text
kubectl --namespace=spark-demo port-forward [driver-pod-name] 4040:4040
```

## Accessing Logs

Find the driver pod.

```text
kubectl --namespace=spark-demo get pod
```

Access the logs.

```text
kubectl --namespace=spark-demo logs -f [driver-pod-name]
```

## Accessing Kubernetes Dashboard

```text
$ minikube dashboard
🔌  Enabling dashboard ...
🤔  Weryfikowanie statusu dashboardu...
🚀  Launching proxy ...
🤔  Weryfikowanie statusu proxy...
🎉  Opening http://127.0.0.1:49755/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

## Stopping Cluster

```text
minikube stop
```

Optionally (e.g. to start from scratch next time), delete all of the minikube clusters:

```text
minikube delete --all
```
