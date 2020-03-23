#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $0)
source $SCRIPT_DIR/../vars.sh
$SCRIPT_DIR/../../common/get-kubectl.sh
$SCRIPT_DIR/../../common/get-helm.sh

NAMESPACE="nginx-ingress"
NGINX_INGRESS_CHART_VERSION="1.34.2"

# create namespace if it doesn't exist
if ! ./kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    ./kubectl create ns "$NAMESPACE"
fi

# update helm stable chart repo
helm repo update

# upgrade helm release
helm upgrade \
    --install \
    --force \
    --wait \
    --version "$NGINX_INGRESS_CHART_VERSION" \
    --namespace "$NAMESPACE" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=true \
    --set controller.service.loadBalancerIP=${INGRESS_LOAD_BALANCER_IP} \
    nginx-ingress \
    stable/nginx-ingress

# set the NSG rule for Internet or VirtualNetwork
az network nsg rule create -g $RESOURCE_GROUP \
    --nsg-name $AKS_NSG_NAME \
    --name INGRESS_CONTROLLER_TCP_80 \
    --priority 600 \
    --source-address-prefixes 'Internet' \
    --source-port-ranges '*' \
    --destination-address-prefixes "$INGRESS_LOAD_BALANCER_IP" \
    --destination-port-ranges 80 443 \
    --access Allow --protocol TCP \
    --description "Allow ingress traffic on port 80 and 443" > /dev/null

echo "Cluster ingress available at http://$INGRESS_LOAD_BALANCER_IP"
