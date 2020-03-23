#!/bin/bash

export HELM_INSTALL_DIR=`pwd`
export DESIRED_VERSION=v3.1.2
export PATH=$PATH:`pwd`

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh --no-sudo
