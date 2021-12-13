#!/bin/bash

set -ea
SCRIPT_DIR=$(dirname $0)
$SCRIPT_DIR/../../common/get-kubectl.sh
$SCRIPT_DIR/get-aks-creds.sh

AKS_ID=`az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --query id -o tsv`

cat <<EOF | ./kubectl apply -f -
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


cat <<EOF | ./kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aad-aks-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: f9b05ccf-6914-40c0-9664-48ef112ade23
EOF

  echo "Add users to $AKS_AD_GROUP_NAME group by running:"
  echo "az ad group member add --group $GROUP_ID --member-id \`az ad user show --id <user principal> --query objectId -otsv\`"
done
