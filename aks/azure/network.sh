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

vnetId=`az network vnet show \
        --name $AKS_VNET_NAME \
        --resource-group $RESOURCE_GROUP \
        --query id --output tsv`

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

az role definition create --role-definition "{ \
    \"Name\": \"$AKS_KUBENET_ROLE\", \
    \"IsCustom\": true, \
    \"Id\": \"7acd4ee3-8ed5-4737-b0c4-5717bcc759df\", \
    \"Description\": \"Used by AKS to read and join subnet.\", \
    \"Actions\": [ \
        \"Microsoft.Network/virtualNetworks/subnets/read\", \
        \"Microsoft.Network/virtualNetworks/subnets/join/action\" \
    ], \
    \"DataActions\": [], \
    \"NotDataActions\": [], \
    \"AssignableScopes\": [ \
        \"/subscriptions/$SUBSCRIPTION\" \
    ] \
}" > /dev/null || :


export AKS_SUBNET_ID=$aksSubnetId
export AKS_VNET_ID=$vnetId
echo "export AKS_SUBNET_ID=$aksSubnetId"
echo "export AKS_VNET_ID=$vnetId"