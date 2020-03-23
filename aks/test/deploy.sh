#!/bin/bash

SCRIPT_DIR=$(dirname $0)
source $SCRIPT_DIR/../vars.sh

az acr import -n $AKS_ACR_NAME --source docker.io/boxboat/hello-world > /dev/null 2>&1 ||:

regcreds=`az acr credential show --name $AKS_ACR_NAME --query passwords[0].value -otsv`
./kubectl create secret docker-registry ${AKS_ACR_NAME}-secret \
  --docker-server=$AKS_ACR_NAME.azurecr.io \
  --docker-username=$AKS_ACR_NAME \
  --docker-password=$regcreds \
  --docker-email=info@placeholder.com

sed "s/\${REGISTRY}/$AKS_ACR_NAME/" $SCRIPT_DIR/hello-world.yaml.tmpl > $SCRIPT_DIR/hello-world.yaml
./kubectl apply -f ${SCRIPT_DIR}/

i=0
for i in `seq 1 5`
do
  SVC_IP=`./kubectl get svc hello-world -ojsonpath='{.status.loadBalancer.ingress[0].ip}'`
  if [ ! "$SVC_IP" = "" ]
  then
    # Create subnet NSG Rule for Internet or VirtualNetwork
    az network nsg rule create -g $RESOURCE_GROUP \
      --nsg-name $AKS_NSG_NAME \
      --name TestApp_TCP_80 \
      --priority 500 \
      --source-address-prefixes 'Internet' \
      --source-port-ranges '*' \
      --destination-address-prefixes "$SVC_IP" \
      --destination-port-ranges '80' \
      --access Allow --protocol TCP \
      --description "Allow test site traffic on port 80" > /dev/null

    echo "Test service available at http://$SVC_IP"
    break
  else 
    sleep 30
  fi
done