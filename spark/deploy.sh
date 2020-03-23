#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $0)
$SCRIPT_DIR/../common/get-kubectl.sh
$SCRIPT_DIR/../common/get-helm.sh

./helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
./helm repo update

NAMESPACE="spark-operator"
SPARK_OPERATOR_CHART_VERSION="0.6.9"

# create namespace if it doesn't exist
if ! ./kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    ./kubectl create ns "$NAMESPACE"
fi

helm upgrade \
    --install \
    --force \
    --wait \
    --version $SPARK_OPERATOR_CHART_VERSION \
    --set operatorVersion=v1beta2-1.1.0-2.4.5 \
    --set ingressUrlFormat='\{\{\$appName\}\}.ingress.cluster.com' \
    --set sparkJobNamespace=default \
    --namespace $NAMESPACE \
    spark-operator \
    incubator/sparkoperator

#    --set enableWebhook=true \

# ./kubectl apply -f $SCRIPT_DIR/manifest/crds/
# ./kubectl apply -f $SCRIPT_DIR/manifest/spark-rbac.yaml
# ./kubectl apply -f $SCRIPT_DIR/manifest/spark-operator-rbac.yaml
# ./kubectl apply -f $SCRIPT_DIR/manifest/spark-rbac.yaml