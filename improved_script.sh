#!/bin/bash

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl and try again."
    exit 1
fi

# Function to print headers
print_header() {
    echo -e "\n***********************************"
    echo "========== MULESOFT PREPROD =========="
    echo "***********************************"
    echo ""
    echo "===== $1 ====="
}

# Function to check the status of the last command
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute $1"
        exit 1
    fi
}

# Print all namespaces
print_header "All Namespace"
kubectl get ns | column -t
check_status "kubectl get ns"

# Print node status
print_header "Node Status"
kubectl get nodes | column -t
check_status "kubectl get nodes"

# Print node count
print_header "Node Count"
kubectl get nodes | wc -l | column -t
check_status "kubectl get nodes | wc -l"

# Print top node resource usage
print_header "Top Node"
kubectl top node | column -t
check_status "kubectl top node"

# Print all pods in all namespaces
print_header "Pod All-Namespace"
kubectl get po -A | column -t
check_status "kubectl get po -A"

# Print pod count in all namespaces
print_header "Pod Count"
kubectl get po -A | wc -l | column -t
check_status "kubectl get po -A | wc -l"

# Print deployment count for specific namespaces
NAMESPACES=("22e933a8-3406-4e81-9382-c5d384ca510d" "31674166-4673-4755-999e-e5bd9a9df150" "4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9" "5a0aca15-8b6c-487b-9a9d-9e92102165a1" "6bb35783-b673-4bc2-adfa-ed083265537b" "b2f05235-ba6b-47a5-9252-3a73f6ee83a5")

print_header "Deployment Count"
kubectl get deploy -A | grep -E "$(IFS=\|; echo "${NAMESPACES[*]}")" | wc -l | column -t
check_status "kubectl get deploy -A | grep -E ..."

# Print application pods count for specific namespaces
print_header "Application Pods Count"
kubectl get pods -A | grep -E "$(IFS=\|; echo "${NAMESPACES[*]}")" | wc -l | column -t
check_status "kubectl get pods -A | grep -E ..."

# Print problematic pods with specific statuses
STATUSES=("0/1" "1/2" "0/2" "2/3" "1/3" "0/3")
for STATUS in "${STATUSES[@]}"; do
    print_header "Problematic Pod $STATUS"
    kubectl get po -A | grep -i "$STATUS" | column -t
done

# Print pods in specific namespaces
for NS in "${NAMESPACES[@]}"; do
    print_header "Pods in namespace $NS"
    kubectl get po -n "$NS" | column -t
    check_status "kubectl get po -n $NS"
    kubectl get po -n "$NS" | wc -l | column -t
    check_status "kubectl get po -n $NS | wc -l"
done

# Print ingress status
print_header "Ingress Status"
kubectl get ing -A | grep nginx | wc -l | column -t
check_status "kubectl get ing -A | grep nginx | wc -l"

# Print non-running pods
print_header "Problematic Pods Except Running"
kubectl get po -A | grep -v Running | column -t
check_status "kubectl get po -A | grep -v Running"

# Print cron jobs
print_header "CronJob"
kubectl get cj -A | column -t
check_status "kubectl get cj -A"

# Print jobs
print_header "Job"
kubectl get job -A | column -t
check_status "kubectl get job -A"

# Print deployment status
print_header "Deployment Status"
kubectl get deploy -A | column -t
check_status "kubectl get deploy -A"
