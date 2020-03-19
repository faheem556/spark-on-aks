#!/bin/bash

SCRIPT_DIR=$(dirname $0)

source $SCRIPT_DIR/vars.sh

# echo "Creating ACR objects"
# ./acr.sh | tee acr.log

# echo "Creating Kubernetes cluster"
# ./aks.sh | tee aks.log

echo "Deleting AAD OAuth objects"
$SCRIPT_DIR/cleanup/aad-cleanup.sh