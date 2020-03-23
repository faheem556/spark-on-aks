#!/bin/bash
set -ea

SCRIPT_DIR=$(dirname $0)

source $SCRIPT_DIR/../vars.sh

echo "Creating AAD OAuth objects"
source ./$SCRIPT_DIR/aad.sh

echo "Create Resource group and SP"
source ./$SCRIPT_DIR/rg.sh 

echo "Setting up Networking"
source ./$SCRIPT_DIR/network.sh 

echo "Creating Kubernetes cluster"
source ./$SCRIPT_DIR/aks.sh

echo "Setting up user access"
source ./$SCRIPT_DIR/aad-access.sh