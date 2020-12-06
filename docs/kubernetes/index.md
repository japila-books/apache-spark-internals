# Kebernetes

`Kebernetes` is among the cluster managers supported by Apache Spark (using [KubernetesClusterManager](KubernetesClusterManager.md)).

Apache Spark supports **k8s://**-prefixed master URLs.

## Minikube

Quoting the [official documentation]({{ spark.doc }}/running-on-kubernetes.html):

> Spark (starting with version 2.3) ships with a Dockerfile that can be used for this purpose, or customized to match an individual application’s needs. It can be found in the `kubernetes/dockerfiles/` directory.
