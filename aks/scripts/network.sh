#!/bin/bash

set -ea

aksSubnetId=""

if ! `az network nsg show --name $AKS_NSG_NAME -g $RESOURCE_GROUP > /dev/null`; 
then
    aksNSG=`az network nsg create \
        --name $AKS_NSG_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $RESOURCE_LOCATION \
        --subscription $SUBSCRIPTION \
        --tags $TAGS `
fi

aksSubnetId=`az network vnet subnet show \
        --name $AKS_SUBNET_NAME \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $AKS_VNET_NAME \
        --output tsv \
        --query id` || :

if [ "$aksSubnetId" = "" ]
then
    aksSubnetId=`az network vnet subnet create \
        --address-prefixes $AKS_SUBNET_CIDR \
        --name $AKS_SUBNET_NAME \
        --resource-group $RESOURCE_GROUP \
        --subscription $SUBSCRIPTION \
        --vnet-name $AKS_VNET_NAME \
        --network-security-group $AKS_NSG_NAME \
        --output tsv \
        --query id`    
fi

export AKS_SUBNET_ID=$aksSubnetId
echo "export AKS_SUBNET_ID=$aksSubnetId"