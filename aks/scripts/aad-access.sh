#!/bin/bash

set -ea

AKS_ID=`az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --query id -o tsv`

if ! ./kubectl version --client > /dev/null;
then
  echo "Download kubectl"
  arch=linux
  if [[ "$OSTYPE" == "darwin"* ]]; then
    arch=darwin
  elif [[ "$OSTYPE" == "win32" ]]; then
    arch=windows
  fi
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/$arch/amd64/kubectl
  chmod +x ./kubectl
fi

echo "Getting cluster credentials"
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --file kube.config --admin
export KUBECONFIG=kube.config
./kubectl version --short

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: cluster-readers
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: cluster-operators
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]
EOF

for AKS_AD_GROUP in `echo $AKS_AD_GROUPS`
do
  AKS_AD_GROUP_NAME=`echo $AKS_AD_GROUP | cut -d':' -f1`
  AKS_AD_ROLE=`echo $AKS_AD_GROUP | cut -d':' -f2`

  echo "Creating group $AKS_AD_GROUP_NAME"

  GROUP_ID=`az ad group create \
        --display-name $AKS_AD_GROUP_NAME \
        --mail-nickname $AKS_AD_GROUP_NAME \
        --query objectId -o tsv`

  sleep 30 # wait for the group to be created

  az role assignment create \
    --assignee $GROUP_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope $AKS_ID > /dev/null

  echo export $AKS_AD_GROUP_NAME=$GROUP_ID

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: az-aad-$AKS_AD_ROLE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-operations
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: $GROUP_ID
EOF

  echo "Add users to $AKS_AD_GROUP_NAME group by running:"
  echo "az ad group member add --group $GROUP_ID --member-id \`az ad user show --id <user principal> --query objectId -otsv\`"
done
