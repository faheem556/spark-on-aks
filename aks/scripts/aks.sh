#!/bin/bash

set -ea

echo "Creating Azure Container Registry"
aksACR=`az acr create \
    --name $AKS_ACR_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $RESOURCE_LOCATION \
    --sku "Standard" \
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

echo "Creating Kubernetes cluster"
echo "az aks create 
    --subscription $SUBSCRIPTION 
    --resource-group $RESOURCE_GROUP 
    --name $AKS_CLUSTER_NAME 
    --location $RESOURCE_LOCATION 
    --no-ssh-key 
    --aad-server-app-id $SERVER_APP_ID 
    --aad-server-app-secret $SERVER_APP_SECRET 
    --aad-client-app-id $CLIENT_APP_ID 
    --aad-tenant-id $TENANT_ID 
    --service-principal $AKS_SP_ID 
    --client-secret $AKS_SP_SECRET 
    --network-plugin $AKS_NETWORK_PLUGIN 
    --network-policy calico 
    --enable-cluster-autoscaler 
    --node-count 1
    --min-count $AKS_NODES_MIN 
    --max-count $AKS_NODES_MAX 
    --load-balancer-sku Standard 
    --enable-private-cluster 
    --pod-cidr $AKS_POD_CIDR 
    --service-cidr $AKS_SERVICE_CIDR 
    --dns-service-ip $AKS_SERVICE_DNS 
    --docker-bridge-address $AKS_DOCKER_BRIDGE_CIDR 
    --node-osdisk-size $AKS_NODE_DISK_SIZE 
    --node-vm-size  $AKS_NODE_VM_SIZE 
    --vm-set-type VirtualMachineScaleSets 
    --enable-addons $AKS_ADDONS 
    --workspace-resource-id $aksLAWSId 
    --vnet-subnet-id $AKS_SUBNET_ID 
    --tags $TAGS   "

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
    --service-principal $AKS_SP_ID \
    --client-secret $AKS_SP_SECRET \
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
    --tags $TAGS 
    #--enable-private-cluster \
    #--skip-subnet-role-assignment

echo "Finished creating cluster"