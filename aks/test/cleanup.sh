#!/bin/bash

set -a
SCRIPT_DIR=$(dirname $0)
source $SCRIPT_DIR/../vars.sh

./kubectl delete -f $SCRIPT_DIR/

az network nsg rule delete -g $RESOURCE_GROUP \
      --nsg-name $AKS_NSG_NAME \
      --name TestApp_TCP_80 \
      --subscription $SUBSCRIPTION