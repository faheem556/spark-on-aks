#!/bin/bash

SCRIPT_DIR=$(dirname $0)

source $SCRIPT_DIR/../vars.sh

serverApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Server" --query [0].appId -otsv`
clientApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Client" --query [0].appId -otsv`

az ad app delete --id $serverApplicationId
az ad app delete --id $clientApplicationId

az group delete -n $RESOURCE_GROUP
az role definition delete --name "$AKS_KUBENET_ROLE" --subscription $SUBSCRIPTION

for AKS_AD_GROUP in `echo $AKS_AD_GROUPS`
do
  AKS_AD_GROUP_NAME=`echo $AKS_AD_GROUP | cut -d':' -f1`
  az ad group delete --g $AKS_AD_GROUP_NAME
done