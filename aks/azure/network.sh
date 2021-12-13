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

#az network route-table create -g $RESOURCE_GROUP --name $FWROUTE_TABLE_NAME
#az network route-table route create -g $RESOURCE_GROUP --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP --subscription $SUBID
#az network route-table route create -g $RESOURCE_GROUP --name $FWROUTE_NAME_INTERNET --route-table-name $FWROUTE_TABLE_NAME --address-prefix $FWPUBLIC_IP/32 --next-hop-type Internet

export AKS_SUBNET_ID=$aksSubnetId
export AKS_VNET_ID=$vnetId
echo "export AKS_SUBNET_ID=$aksSubnetId"
echo "export AKS_VNET_ID=$vnetId"