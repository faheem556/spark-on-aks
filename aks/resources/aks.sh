#!/bin/bash



aksACR=`az acr create 
    --name $AKS_ACR_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $RESOURCE_LOCATION \
    --sku "Standard" \
    --tags $TAGS `

echo $aksACR

# az aks create \
#     --subscription $SUBSCRIPTION
#     --resource-group $RESOURCE_GROUP \
#     --name $AKS_CLUSTER_NAME \
#     --location $RESOURCE_LOCATION \
#     --no-ssh-key \
#     --aad-server-app-id $SERVER_APP_ID \
#     --aad-server-app-secret $SERVER_APP_SECRET \
#     --aad-client-app-id $CLIENT_APP_ID \
#     --aad-tenant-id $TENANT_ID \
#     --enable-rbac \
#     --service-principal $AKS_SP_ID \
#     --client-secret $AKS_SP_SECRET \
#     --network-plugin $AKS_NETWORK_PLUGIN \
#     --network-policy calico \
#     --enable-cluster-autoscaler \
#     --min-count 1 \
#     --max-count 5 \
#     --service-cidr $AKS_SERVICE_CIDR \
#     --dns-service-ip $AKS_SERVICE_DNS \
#     --docker-bridge-address $AKS_DOCKER_BRIDGE_CIDR \

#     [--node-osdisk-size]
#     --node-vm-size
#     --vm-set-type VirtualMachineScaleSets
#     #[--pod-cidr]
    
#     --service-principal
#     [--skip-subnet-role-assignment]
    
#     --enable-addons $AKS_ADDONS \
#     --workspace-resource-id \
#     --vnet-subnet-id $aksSubnet.Id
#     --tags $TAGS
    

