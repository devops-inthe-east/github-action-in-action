#!/bin/bash

# Get the cluster name from kubectl
CLUSTER=$(kubectl config current-context)

# Ask for user input
read -p "Enter username: " USER

# Create a new namespace for the user
kubectl create ns $USER

# Generate a private key and certificate signing request (CSR)
openssl req -nodes -newkey rsa:2048 -keyout $USER.key -out $USER.csr -subj "/CN=$USER" > /dev/null

# Create a CertificateSigningRequest (CSR) YAML file
cat > csr.yaml <<-EOF
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  groups:
  - system:authenticated
  request: $(cat $USER.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Apply the CSR YAML file to create a CertificateSigningRequest object in Kubernetes
kubectl apply -f csr.yaml

# Approve the CSR to generate a certificate for the user's private key 
kubectl certificate approve $USER 

# Extract the approved certificate from Kubernetes and save it to $USER.crt 
CERT=$(kubectl get csr $USER -o jsonpath='{.status.certificate}') && echo "$CERT" | base64 --decode > $USER.crt 

 # Configure Kubeconfig 
kubectl config set-credentials $USER --client-key=$USER.key --client-certificate=$USER.crt --embed-certs=true 

 # Set context 
kubectl config set-context default-$CLUSTER-$NS-$CLUSTER --cluster=$CLUSTER--user=$USERSYSTEMD--namespace=$NS 

 # Use context 
kubectl config use-context default-$CLUSTER-$NS-$CLUSTER  

 # Clean-up files  
rm csr.yaml  
rm *$USERSYSTEMD.*  

echo "Kubeconfig created successfully!"
