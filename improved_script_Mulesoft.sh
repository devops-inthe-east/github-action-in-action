#!/bin/bash

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl and try again."
    exit 1
fi

# Function to check the status of the last command
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute $1"
        exit 1
    fi
}

# Function to get the count of a kubectl resource
get_count() {
    kubectl get "$1" -A | wc -l
}

# Print header
echo -e "\n***********************************"
echo "========== MULESOFT PREPROD =========="
echo "***********************************"

# Collect counts
namespace_count=$(get_count ns)
node_count=$(get_count nodes)
pod_count=$(get_count po)
deployment_count=$(kubectl get deploy -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | wc -l)
app_pod_count=$(kubectl get pods -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | wc -l)
ingress_count=$(kubectl get ing -A | grep nginx | wc -l)

# Print counts in a table
echo -e "\n===== Summary ====="
echo -e "Component\tCount"
echo -e "---------\t-----"
echo -e "Namespaces\t$namespace_count"
echo -e "Nodes\t\t$node_count"
echo -e "Pods\t\t$pod_count"
echo -e "Deployments\t$deployment_count"
echo -e "App Pods\t$app_pod_count"
echo -e "Ingress\t\t$ingress_count"
echo ""

# Print all namespaces
echo "===== All Namespace ====="
kubectl get ns | column -t
check_status "kubectl get ns"

# Print node status
echo -e "\n===== Node Status ====="
kubectl get nodes | column -t
check_status "kubectl get nodes"

# Print top node resource usage
echo -e "\n===== Top Node ====="
kubectl top node | column -t
check_status "kubectl top node"

# Print all pods in all namespaces
echo -e "\n===== Pod All-Namespace ====="
kubectl get po -A | column -t
check_status "kubectl get po -A"

# Print deployment count for specific namespaces
echo -e "\n===== Deployment Details ====="
kubectl get deploy -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | column -t
check_status "kubectl get deploy -A | grep -E ..."

# Print application pods count for specific namespaces
echo -e "\n===== Application Pods Details ====="
kubectl get pods -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | column -t
check_status "kubectl get pods -A | grep -E ..."

# Print problematic pods with specific statuses
STATUSES=("0/1" "1/2" "0/2" "2/3" "1/3" "0/3")
for STATUS in "${STATUSES[@]}"; do
    echo -e "\n===== Problematic Pods ($STATUS) ====="
    kubectl get po -A | grep -i "$STATUS" | column -t
done

# Print pods in specific namespaces
NAMESPACES=("b2f05235-ba6b-47a5-9252-3a73f6ee83a5" "22e933a8-3406-4e81-9382-c5d384ca510d" "6bb35783-b673-4bc2-adfa-ed083265537b" "5a0aca15-8b6c-487b-9a9d-9e92102165a1" "31674166-4673-4755-999e-e5bd9a9df150")
for NS in "${NAMESPACES[@]}"; do
    echo -e "\n===== Pods in namespace $NS ====="
    kubectl get po -n "$NS" | column -t
    check_status "kubectl get po -n $NS"
    echo -e "\nTotal Pods in namespace $NS: "
    kubectl get po -n "$NS" | wc -l | column -t
    check_status "kubectl get po -n $NS | wc -l"
done

# Print non-running pods
echo -e "\n===== Problematic Pods Except Running ====="
kubectl get po -A | grep -v Running | column -t
check_status "kubectl get po -A | grep -v Running"

# Print cron jobs
echo -e "\n===== CronJobs ====="
kubectl get cj -A | column -t
check_status "kubectl get cj -A"

# Print jobs
echo -e "\n===== Jobs ====="
kubectl get job -A | column -t
check_status "kubectl get job -A"

# Print deployment status
echo -e "\n===== Deployment Status ====="
kubectl get deploy -A | column -t
check_status "kubectl get deploy -A"
