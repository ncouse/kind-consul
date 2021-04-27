# Consul on Kind Test

This is a simple test setup to demonstrate issues with Consul on a KinD cluster.

This will install a 4 node cluster (one control plane and 3 workers).

Then it will install Consul using consul-helm v0.31.1

## Prerequisites

* Docker
* Go
* helm
* kubectl

## Notes

Creating the KinD cluster should not take more than a few minutes.

The first run will require to download a docker image for the node, which is over 400MB.

See [KinD homepage](https://kind.sigs.k8s.io/) for more details on KinD.

