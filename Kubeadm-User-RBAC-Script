#!/bin/bash

# Function to prompt for input
prompt() {
    read -p "$1: " INPUT
    echo $INPUT
}

# Function to check if a value is empty
check_empty() {
    if [ -z "$1" ]; then
        echo "Inputs cannot be blank. Please try again!"
        exit 1
    fi
}

# Prompt for user and namespace
USER=$(prompt "Enter user")
check_empty $USER
NS=$(prompt "Enter the namespace to create")
check_empty $NS

# Generate certificate
openssl req -nodes -newkey rsa:2048 -keyout $USER.key -out $USER.csr -subj "/C=DE/ST=Germany/L=Ratingen/O=Vodafone Group Services GmbH/OU=GKS/CN=$USER" > /dev/null
CSR=$(cat $USER.csr | base64 | tr -d "\n")

# Create CSR YAML
cat > csr.yaml <<-EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  groups:
  - system:authenticated
  request: $CSR
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Create namespace
kubectl create ns $NS

# Apply CSR and approve it
kubectl apply -f csr.yaml
kubectl certificate approve $USER
CERT=$(kubectl get csr $USER -o jsonpath='{.status.certificate}')
echo $CERT | base64 -d > $USER.crt

# Extract cluster information from the existing kubeconfig file
ORIGINAL_KUBECONFIG=$(kubectl config view --raw)
CLUSTER_NAME=$(echo "$ORIGINAL_KUBECONFIG" | grep -m 1 'name:' | awk '{print $2}')
CLUSTER_SERVER=$(echo "$ORIGINAL_KUBECONFIG" | grep 'server:' | awk '{print $2}')
CLUSTER_CA=$(echo "$ORIGINAL_KUBECONFIG" | grep 'certificate-authority-data:' | awk '{print $2}')

# Create kubeconfig for the user
KUBECONFIG_FILE=${USER}_config

kubectl config set-cluster $CLUSTER_NAME \
    --certificate-authority=$CLUSTER_CA \
    --server=$CLUSTER_SERVER \
    --kubeconfig=$KUBECONFIG_FILE

kubectl config set-credentials $USER \
    --client-key=$USER.key \
    --client-certificate=$USER.crt \
    --embed-certs=true \
    --kubeconfig=$KUBECONFIG_FILE

kubectl config set-context $USER \
    --cluster=$CLUSTER_NAME \
    --namespace=$NS \
    --user=$USER \
    --kubeconfig=$KUBECONFIG_FILE

kubectl config use-context $USER --kubeconfig=$KUBECONFIG_FILE

# Create role and rolebinding
kubectl create role $USER-role --verb=* --resource=pods,deployments,replicasets,services,ingress,statefulsets -n $NS
kubectl create rolebinding $USER-rolebinding --role=$USER-role --user=$USER -n $NS

# Cleanup
rm csr.yaml $USER.csr $USER.key
PWD=$(pwd)

# Output message
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
echo -e "${GREEN}###########################################################################"
echo -e "${GREEN}Kubeconfig exported at $PWD with name ${YELLOW}${USER}_config"
echo -e "${GREEN}Rename it to config and copy it to user home directory at ~/.kube to use it"
echo -e "${GREEN}Role and Rolebinding also created for namespace ${YELLOW}$NS"
echo -e "${GREEN}Thanks :)"
echo -e "${GREEN}###########################################################################${NC}"
