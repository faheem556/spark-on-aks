#!/bin/bash

SCRIPT_DIR=$(dirname $0)

source $SCRIPT_DIR/vars.sh

serverApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Server" --query [0].appId -otsv`
clientApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Client" --query [0].appId -otsv`

az ad app   delete --id $serverApplicationId
az ad app   delete --id $clientApplicationId

az ad sp delete --id http://$AKS_SP_NAME
az group delete -n $RESOURCE_GROUP

for AKS_AD_GROUP in `echo $AKS_AD_GROUPS`
do
  AKS_AD_GROUP_NAME=`echo $AKS_AD_GROUP | cut -d':' -f1`
  az ad group delete --g $AKS_AD_GROUP_NAME
done