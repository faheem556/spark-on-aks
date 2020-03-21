#!/bin/bash

set -a

export NAME_PREFIX="aks-demo"
export TENANT_ID=$(az account show --query tenantId -o tsv)
export SUBSCRIPTION=$(az account show --query id -o tsv)
export RESOURCE_GROUP="${NAME_PREFIX}"
export RESOURCE_LOCATION="centralus"

export AKS_CLUSTER_NAME="${NAME_PREFIX}-cluster"
export AKS_ACR_NAME="aksdemobb"

export AKS_VNET_NAME="${NAME_PREFIX}-vnet"
export AKS_SUBNET_NAME="${NAME_PREFIX}-subnet"
export AKS_NSG_NAME="${NAME_PREFIX}-nsg"
export AKS_SP_NAME="${NAME_PREFIX}-cluster-sp"

export AKS_AD_GROUPS="aks-admins:admins" #Roles: admins, readers, operators

export AKS_SUBNET_CIDR="172.22.20.0/24"
export AKS_DOCKER_BRIDGE_CIDR="172.19.0.1/16"
export AKS_POD_CIDR="172.20.0.0/16"
export AKS_SERVICE_CIDR="10.0.0.0/16"
export AKS_SERVICE_DNS="10.0.0.10"
export AKS_NETWORK_PLUGIN="kubenet"

export AKS_NODE_DISK_SIZE="64"
export AKS_NODE_VM_SIZE="Standard_DS13_v2" # Standard_E16s_v3
export AKS_NODES_MIN=1
export AKS_NODES_MAX=2

export AKS_LAWS_NAME="${NAME_PREFIX}-laws"
export AKS_LAWS_RETENTION=60 # days
export AKS_ADDONS="monitoring"

export TAGS="Owner=email@domain.com Automation=false CostCenter=1234"