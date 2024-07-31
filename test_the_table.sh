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
if! command -v kubectl &> /dev/null; then
    echo "kubectl not found."
    exit 1
fi

# Function to check the status of the last command
check_status() {
    if [ $? -ne 0 ]; then
        print_color "$RED" "Error: Failed"
        exit 1
    fi
}

# Function to get the count of a kubectl resource
get_count() {
    local resource=$1
    local count=$(kubectl get "$resource" -A | wc -w)
    echo "$count"
}

# Print header
echo -e "\n***********************************"
echo "========== MULESOFT PREPROD =========="
echo "***********************************"

# Collect counts
namespace_count=$(get_count ns)
node_count=$(get_count nodes)
kube_system_pod_count=$(kubectl get pods -A | grep -F 'kube-system' | wc -w)
pod_count=$(get_count po)
app_deployment_count=$(kubectl get deploy -A | grep -Ff <(printf "%s\n" '22e933a8-3406-4e81-9382-c5d384ca510d' '31674166-4673-4755-999e-e5bd9a9df150' '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9' '5a0aca15-8b6c-487b-9a9d-9e92102165a1' '5a0aca15-8b6c-487b-9a9d-9e92102165a' '6bb35783-b673-4bc2-adfa-ed083265537b' 'b2f05235-ba6b-47a5-9252-3a73f6ee83a5') | wc -w)
app_pod_count=$(kubectl get pods -A | grep -Ff <(printf "%s\n" '22e933a8-3406-4e81-9382-c5d384ca510d' '31674166-4673-4755-999e-e5bd9a9df150' '4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9' '5a0aca15-8b6c-487b-9a9d-9e92102165a1' '5a0aca15-8b6c-487b-9a9d-9e92102165a' '6bb35783-b673-4bc2-adfa-ed083265537b' 'b2f05235-ba6b-47a5-9252-3a73f6ee83a5') | wc -w)
ingress_count=$(kubectl get ing -A | grep nginx | wc -w)

# Print counts in a table with colors
echo -e "\n===== Summary ====="
print_color "$YELLOW" "Component\tCount"
print_color "$YELLOW" "---------\t-----"
print_color "$CYAN" "Namespaces\t$namespace_count"
print_color "$CYAN" "Nodes\t\t$node_count"
print_color "$CYAN" "Kube-System-Pod\t\t$kube_system_pod_count"
print_color "$CYAN" "Pods\t\t$pod_count"
print_color "$CYAN" "Deployments\t$app_deployment_count"
print_color "$CYAN" "App Pods\t$app_pod_count"
print_color "$CYAN" "Ingress\t\t$ingress_count"
echo ""
