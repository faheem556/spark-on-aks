#!/bin/bash

serverApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Server" --query [0].appId -otsv`
clientApplicationId=`az ad app list --display-name "${AKS_CLUSTER_NAME}Client" --query [0].appId -otsv`

az ad app   delete --id $serverApplicationId
az ad app   delete --id $clientApplicationId