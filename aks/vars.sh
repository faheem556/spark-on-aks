#!/bin/bash

set -e

export TENANT_ID=$(az account show --query tenantId -o tsv)
export SUBSCRIPTION=$(az account show --query id -o tsv)
export RESOURCE_GROUP="aks-demo"
export RESOURCE_LOCATION="centralus"

export AKS_CLUSTER_NAME="aks-demo-cluster"
export AKS_ACR_NAME="aksdemobb"

export AKS_VNET_NAME="aks-demo-vnet"
export AKS_SUBNET_NAME="aks-demo-subnet"
export AKS_NSG_NAME="aks-demo-nsg"
export AKS_SP_NAME="aks-demo-cluster-sp"

export AKS_SUBNET_CIDR="172.22.20.0/24"
export AKS_DOCKER_BRIDGE_CIDR="172.19.0.0/16"
export AKS_SERVICE_CIDR="10.0.0.0/16"
export AKS_SERVICE_DNS="10.0.0.10"
export AKS_NETWORK_PLUGIN="kubenet"

export AKS_ADDONS="monitoring"

export TAGS="Owner=email@domain.com Automation=false CostCenter=1234"