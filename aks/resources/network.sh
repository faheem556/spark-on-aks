#!/bin/bash

aksNSG=`az network nsg create \
    --name $AKS_NSG_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $RESOURCE_LOCATION \
    --subscription $SUBSCRIPTION \
    --tags $TAGS `

aksSubnet=`az network vnet subnet create \
    --address-prefixes $AKS_SUBNET_CIDR \
    --name $AKS_SUBNET_NAME \ 
    --resource-group $RESOURCE_GROUP \
    --subscription $SUBSCRIPTION \
    --vnet-name $AKS_VNET_NAME \
    --network-security-group $AKS_NSG_NAME \
    --output tsv \
    --query id`

export AKS_SUBNET_ID=$aksSubnetId

echo "export AKS_SUBNET_ID=$aksSubnetId"