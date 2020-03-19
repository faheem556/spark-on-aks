#!/bin/bash

rgId=""

if `az group show --name $RESOURCE_GROUP > /dev/null`; 
then
    rgId=`az group show \
        --name $RESOURCE_GROUP \
        --output tsv \
        --query id`
else
    rgId=`az group create \
        --name $RESOURCE_GROUP \
        --location $RESOURCE_LOCATION \
        --output tsv \
        --query id`
fi

aksSP=`az ad sp create-for-rbac \
  --name http://$AKS_SP_NAME  \
  --scopes $rgId \
  --role contributor \
  --years 10 \
  --output tsv`

export RESOURCE_GROUP_ID=$rgId
export AKS_SP_ID=$(echo $aksSP | cut -f1)
export AKS_SP_SECRET=$(echo $aksSP | cut -f4)

echo "export RESOURCE_GROUP_ID=$rgId"
echo "export AKS_SP_ID=$(echo $aksSP | cut -f1 -d' ')"
echo "export AKS_SP_SECRET=$(echo $aksSP | cut -f4 -d' ')"
echo ""
