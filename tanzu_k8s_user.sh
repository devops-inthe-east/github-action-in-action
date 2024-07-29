#!/bin/bash

unset TANZU
read -p "Enter the TKG binary name (tkg/tanzu): " TANZU
if [ $TANZU != 'tkg' ] && [ $TANZU != 'tanzu' ]
then
    echo "invalid inputs are not accepted. Please try again!"
    exit 0
fi

rm -rf /tmp/cluster
if [ "$TANZU" == "tkg" ]
then
    /usr/local/bin/tkg get clusters | awk '{print $1}' > /tmp/cluster 2>&1
else
    /usr/local/bin/tanzu cluster list | awk '{print $1}' > /tmp/cluster 2>&1
fi

unset VALID
read -p "Enter user: " USER

cat /tmp/cluster
echo "Choose the cluster from above list"
read -p "Enter Cluster Name: " CLUSTER
read -p "Enter the namespace to create: " NS
if [ -z "$USER" ] || [ -z "$CLUSTER" ] || [ -z "$NS" ]
then
    echo 'Inputs cannot be blank please try again!'
    exit 0
fi
VALID=false
for CLS in `cat /tmp/cluster`
 do

        if [ "$CLS" == "$CLUSTER" ]
        then
           VALID=true
        fi
done

if [ $VALID == 'false' ]
then
    echo "Please enter the correct cluster name"
    exit 0
fi

openssl req -nodes -newkey rsa:2048 -keyout $USER.key -out $USER.csr -subj "/C=DE/ST=Germany/L=Ratingen/O=Vodafone Group Services GmbH/OU=GKS/CN=$USER" > /dev/null

CSR=$(cat $USER.csr | base64 | tr -d "\n")
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

kubectl config use-context $CLUSTER\-admin@$CLUSTER
kubectl create ns $NS
kubectl apply -f csr.yaml
kubectl certificate approve $USER
CERT=$(kubectl get csr $USER -oyaml | grep " certificate:" | awk -F: '{print $2}')
echo $CERT | base64 -d > $USER.crt

if [ "$TANZU" == "tkg" ]
then
    /usr/local/bin/tkg get credentials $CLUSTER --export-file $USER\_config
else
    /usr/local/bin/tanzu cluster kubeconfig get $CLUSTER --export-file $USER\_config --admin
fi
kubectl config set-credentials $USER --client-key=$USER.key --client-certificate=$USER.crt --embed-certs=true --kubeconfig=$USER\_config
kubectl config set-context $USER --cluster=$CLUSTER --user=$USER  --kubeconfig=$USER\_config
kubectl config use-context $USER  --kubeconfig=$USER\_config
kubectl config set-context --current --namespace=$NS  --kubeconfig=$USER\_config
kubectl config delete-context $CLUSTER\-admin@$CLUSTER --kubeconfig=$USER\_config
kubectl config unset users.$CLUSTER\-admin --kubeconfig=$USER\_config
kubectl create role $USER\-role --verb=* --resource=pods,deployments,replicasets,service,ingress,statefulsets -n $NS
kubectl create rolebinding $USER\-rolebinding --role=$USER\-role --user=$USER -n $NS
rm csr.yaml $USER.* /tmp/cluster
PWD=$(pwd)

echo -e "\n"
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
echo -e "${GREEN}###########################################################################"

echo -e "${GREEN}Kubeconfig exported at $PWD with name ${YELLOW}${USER}_config"
echo -e "${GREEN}Rename it to config and copy it to user home directory at ~./kube to use it"
echo -e "${GREEN}Role and Rolebinding also created for namespace ${YELLOW}$NS"
echo -e "${GREEN}Thanks :) "

echo -e "${GREEN}###########################################################################${NC}"
