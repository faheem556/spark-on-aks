#!/bin/bash

SCRIPT_DIR=$(dirname $0)

source $SCRIPT_DIR/vars.sh

echo "Creating AAD OAuth objects"
$SCRIPT_DIR/resources/aad.sh | tee -a aad.log

echo "Create Resource group and SP"
./$SCRIPT_DIR/resources/rg.sh | tee rg.log

echo "Setup Networking"
./$SCRIPT_DIR/resources/network.sh | tee network.log

echo "Creating Kubernetes cluster"
./$SCRIPT_DIR/resources/aks.sh | tee aks.log