# Create service account in default namespace
kubectl create sa cicd -n default

# Extract SA credentials
$TOKEN_NAME=kubectl get sa cicd -ojsonpath="{.secrets[0].name}"
$TOKEN=kubectl get secret $TOKEN_NAME -ojsonpath="{.data.token}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($TOKEN)) > token
$CA_CRT=kubectl get secret $TOKEN_NAME -ojsonpath="{.data.ca\.crt}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($CA_CRT)) > ca.crt

# Get API Server URL
$CLUSTER_URL=kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
$CLUSTER_NAME=kubectl config view --minify -o jsonpath='{.clusters[0].name}'

# Create CICD Role
kubectl create clusterrole cicd --verb=* --resource=pods,svc,deploy,rs,secrets,cm,jobs,ingress

# Assign CICD Role to the account in default namespace
kubectl create rolebinding default-cicd --clusterrole=cicd --serviceaccount=default:cicd

# Generate kube.config
kubectl config set-cluster "$CLUSTER_NAME" --kubeconfig=cicd-sa-config --server="$CLUSTER_URL" --certificate-authority="./ca.crt" --embed-certs
kubectl config set-credentials "cicd-sa" --kubeconfig=cicd-sa-config --token="$(cat token)"
kubectl config set-context "${CLUSTER_NAME}-cicd-sa" --cluster="$CLUSTER_NAME" --kubeconfig=cicd-sa-config --user=cicd-sa
kubectl config use-context "${CLUSTER_NAME}-cicd-sa" --kubeconfig=cicd-sa-config

# Test
kubectl get all --kubeconfig=cicd-sa-config

# https://docs.gitlab.com/ee/ci/variables/#variable-type