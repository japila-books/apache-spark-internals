# Spark on Kubernetes

[Kubernetes](https://kubernetes.io/) is an open-source system for automating deployment, scaling, and management of containerized applications.

Apache Spark supports `Kubernetes` resource manager as a scheduler using [KubernetesClusterManager](KubernetesClusterManager.md) for **k8s://**-prefixed master URLs (that point at a [Kubernetes API server](https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver)).

## Demo

1. [spark-shell on minikube](../demo/spark-shell-on-minikube.md)
1. [Running Spark Application on minikube](../demo/running-spark-application-on-minikube.md)

## Resources

* [Official documentation]({{ spark.doc }}/running-on-kubernetes.html)
* [Spark on Kubernetes](https://levelup.gitconnected.com/spark-on-kubernetes-3d822969f85b) by Scott Haines
* (video) [Getting Started with Apache Spark on Kubernetes](https://www.youtube.com/watch?v=xo7BIkFWQP4) by Jean-Yves Stephan and Julien Dumazert
