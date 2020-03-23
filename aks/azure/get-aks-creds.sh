#!/bin/bash

SCRIPT_DIR=$(dirname $0)
source $SCRIPT_DIR/../vars.sh

echo "Getting cluster credentials"
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin --overwrite-existing
