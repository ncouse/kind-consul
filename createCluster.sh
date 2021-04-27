#!/bin/bash

##
# Quick script to install KinD cluster with Consul to demonstrate chart issues.
#
# Pre-requisites:
#  * Go
#  * kubectl
#  * helm
##

KIND_VERSION=0.10.0
CONSUL_CHART_VERSION=0.31.1

######

set -e
DIR=$(readlink -f $(dirname $0))

KIND_CONFIG_FILE=$DIR/cfg/kind-config.yaml
CONSUL_VALUES_FILE=$DIR/cfg/consul-values.yaml
CLUSTER_NAME=kind-consul-test
TMP_DIR=${DIR}/tmp
NAMESPACE=consul

KUBECONF=${TMP_DIR}/${CLUSTER_NAME}.conf

KUBEARGS="--kubeconfig=${KUBECONF}"

######

# Install KinD
GO111MODULE="on" go get sigs.k8s.io/kind@v${KIND_VERSION}

# Create the cluster - this may take a few minutes
kind create cluster --config ${KIND_CONFIG_FILE} --name ${CLUSTER_NAME} -v 0

# Normally kind will update ~/.kube/conf - Can explicitly export file like this
kind get kubeconfig --name ${CLUSTER_NAME} > ${KUBECONF}

>&2 echo "Cluster installed. Kube Conf file is: ${KUBECONF}"

# Now install Consul
helm upgrade --install consul --namespace ${NAMESPACE} --create-namespace --wait --values ${CONSUL_VALUES_FILE} https://github.com/hashicorp/consul-helm/archive/v${CONSUL_CHART_VERSION}.tar.gz

# Let things settle down - probably not necessary
echo "Consul installed - taking a rest"
sleep 30

# Check the client agent nodes
PODS=$(kubectl ${KUBEARGS} -n ${NAMESPACE} get pods -l component=client -o name)
echo "Checking agent pods Node IDs"
for POD in ${PODS}
do
    echo "Pod: ${POD} -- Boot ID = $(kubectl ${KUBEARGS} -n ${NAMESPACE} exec ${POD} -- cat /proc/sys/kernel/random/boot_id)"
done

# Output catalog from each node to demonstrate issues
echo "Checking agent pods catalog"
for POD in ${PODS}
do
    echo "Checking pod: ${POD}"
    kubectl ${KUBEARGS} -n ${NAMESPACE} exec ${POD} -- consul catalog nodes
done

echo "------------------------------------------"
echo "To delete cluster when finished:"
echo "   kind delete cluster --name ${CLUSTER_NAME}"
echo "Kube config file: ${KUBECONF}"


