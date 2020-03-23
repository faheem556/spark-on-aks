#!/bin/bash

set -ea

echo "Creating Azure Container Registry"
aksACRId=`az acr create \
    --name $AKS_ACR_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $RESOURCE_LOCATION \
    --admin-enabled true \
    --sku "Standard" \
    --query id --output tsv \
    --tags $TAGS `

echo "Creating Log Analytics Workspace"
aksLAWSId=`az monitor log-analytics workspace create \
            --workspace-name $AKS_LAWS_NAME \
            --retention-time $AKS_LAWS_RETENTION \
            --resource-group $RESOURCE_GROUP \
            --location $RESOURCE_LOCATION \
            --subscription $SUBSCRIPTION \
            --tags $TAGS \
            --output tsv \
            --query id`    

if az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP > /dev/null; then
  read -p "$AKS_CLUSTER_NAME already exists. Do you want to delete? " answer
  if [ "$answer" != "${answer#[Yy]}" ] ;then
    az aks delete -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --yes
  else
    exit 1
  fi
fi

echo "Creating Kubernetes cluster"
az aks create \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --location $RESOURCE_LOCATION \
    --no-ssh-key \
    --aad-server-app-id $SERVER_APP_ID \
    --aad-server-app-secret $SERVER_APP_SECRET \
    --aad-client-app-id $CLIENT_APP_ID \
    --aad-tenant-id $TENANT_ID \
    --enable-managed-identity \
    --network-plugin $AKS_NETWORK_PLUGIN \
    --network-policy calico \
    --enable-cluster-autoscaler \
    --node-count 1 \
    --min-count $AKS_NODES_MIN \
    --max-count $AKS_NODES_MAX \
    --load-balancer-sku Standard \
    --pod-cidr $AKS_POD_CIDR \
    --service-cidr $AKS_SERVICE_CIDR \
    --dns-service-ip $AKS_SERVICE_DNS \
    --docker-bridge-address $AKS_DOCKER_BRIDGE_CIDR \
    --node-osdisk-size $AKS_NODE_DISK_SIZE \
    --node-vm-size  $AKS_NODE_VM_SIZE \
    --vm-set-type VirtualMachineScaleSets \
    --enable-addons $AKS_ADDONS \
    --workspace-resource-id $aksLAWSId \
    --vnet-subnet-id $AKS_SUBNET_ID \
    --skip-subnet-role-assignment \
    --enable-private-cluster \
    --tags $TAGS 

principalId=`az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --query identity.principalId -otsv`

echo "Attaching ACR"
az role assignment create --assignee $principalId --scope $aksACRId --role AcrPull

echo "Fixing permissions"
az role assignment create --assignee $principalId --scope $AKS_VNET_ID --role $AKS_KUBENET_ROLE
