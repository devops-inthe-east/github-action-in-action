#!/bin/bash
# Function to print text in a specific color
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}
# Colors
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl and try again."
    exit 1
fi

# Function to check the status of the last command
check_status() {
    if [ $? -ne 0 ]; then
        print_color "$RED" "Error: Failed to execute $1"
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
kube_system_pod_count=$(kubectl get po -n kube-system | wc -l)
deamon_set_count=$(kubectl get daemonset -A | wc -l )
pod_count=$(get_count po)
app_deployment_count=$(kubectl get deploy -A | grep -E '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9x'| wc -l)
app_pod_count=$(kubectl get pods -A | grep -E '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9x'| wc -l)
ingress_count=$(kubectl get ing -A | grep nginx | wc -l)

# Print counts in a table with colors
echo -e "\n===== Summary ====="
print_color "$YELLOW" "Component\tCount"
print_color "$YELLOW" "---------\t-----"
print_color "$CYAN" "Namespaces:\t$namespace_count"
print_color "$CYAN" "Nodes:\t\t$node_count"
print_color "$CYAN" "KubeS-Pods:\t$kube_system_pod_count"
print_color "$CYAN" "Pods:\t\t$pod_count"
print_color "$CYAN" "DeamonSet:\t$deamon_set_count"
print_color "$CYAN" "Deployments:\t$app_deployment_count"
print_color "$CYAN" "App Pods:\t$app_pod_count"
print_color "$CYAN" "Ingress:\t$ingress_count"
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
kubectl get deploy -A | grep -E '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9x'| column -t
check_status "kubectl get deploy -A | grep -E ..."

# Print application pods count for specific namespaces
echo -e "\n===== Application Pods Details ====="
kubectl get pods -A | grep -E '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9x'| column -t
check_status "kubectl get pods -A | grep -E ..."

# Print problematic pods with specific statuses
STATUSES=("0/1" "1/2" "0/2" "2/3" "1/3" "0/3")
for STATUS in "${STATUSES[@]}"; do
    echo -e "\n===== Problematic Pods (${STATUS}) ====="
    kubectl get po -A | grep -i "${STATUS}" | column -t
done

# Print pods in specific namespaces
NAMESPACES=("4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9" "4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9x")
for NS in "${NAMESPACES[@]}"; do
    echo -e "\n===== Pods in namespace ${NS} ====="
    kubectl get po -n "${NS}" | column -t
    check_status "kubectl get po -n ${NS}"
    echo -e "\nTotal Pods in namespace ${NS}: "
    kubectl get po -n "${NS}" | wc -l | column -t
    check_status "kubectl get po -n ${NS} | wc -l"
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

echo -e "\n===== Deamonset Status ====="
kubectl get ds -A | column -t
check_status "kubectl get ds -A"
