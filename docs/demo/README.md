# Apache Spark Internals Demos

This directory contains hands-on demonstrations of Apache Spark internals and deployment scenarios.

## Available Demos

### 1. [DiskBlockManager and Block Data](diskblockmanager-and-block-data.md)

Learn how Spark stores data blocks on local disk using DiskBlockManager and DiskStore.

**What you'll learn:**
- Configure local directories for block storage
- Observe how Spark persists data blocks to disk
- Explore block file structure and organization
- Use the web UI to monitor cached RDDs
- Enable detailed logging for block storage internals

**Key components covered:**
- DiskBlockManager
- DiskStore
- StorageLevel
- Block file layout

### 2. [Spark Shell on Minikube](spark-shell-on-minikube.md)

Run Spark shell on Kubernetes using minikube for local development and testing.

**What you'll learn:**
- Set up a local Kubernetes cluster with minikube
- Build Spark Docker images for Kubernetes
- Configure and run spark-shell on Kubernetes
- Monitor executor pod allocation and lifecycle
- Access Kubernetes dashboard for cluster management

**Key components covered:**
- KubernetesClusterSchedulerBackend
- ExecutorPodsAllocator
- ExecutorPodsWatcher
- Spark on Kubernetes deployment

## Prerequisites

- Apache Spark installation
- Basic understanding of Spark architecture
- For Kubernetes demo: Docker and minikube installed

## Getting Started

Choose a demo based on your learning goals:
- For understanding **storage internals**, start with the DiskBlockManager demo
- For learning about **Kubernetes deployment**, explore the Minikube demo

Each demo includes step-by-step instructions and expected outputs to help you understand Spark's internal behavior.
