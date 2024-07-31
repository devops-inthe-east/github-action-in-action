#!/bin/bash

# Function to print header
print_header() {
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
    echo -e "${BLUE}***********************************"
    echo -e "========== MULESOFT PREPROD ==========="
    echo -e "***********************************${NC}"
}

# Function to print counts table
print_counts_table() {
    BLUE='\033[0;34m'
    echo -e "${BLUE}\n===== Summary =====\n"
    echo -e "Components\tCount"
    echo -e "----------\t-----"
    echo -e "Namespaces\t$(kubectl get ns --no-headers | wc -l)"
    echo -e "Nodes\t\t$(kubectl get node --no-headers | wc -l)"
    echo -e "Pods\t\t$(kubectl get po -A --no-headers | wc -l)"
    echo -e "Deployments\t$(kubectl get deploy -A --no-headers | wc -l)"
    echo -e "Ingress\t\t$(kubectl get ing -A | grep nginx --no-headers | wc -l)"
    echo -e "Jobs\t\t$(kubectl get job -A --no-headers | wc -l)"
    echo -e "CronJobs\t$(kubectl get cj -A --no-headers | wc -l)"
    echo -e "${NC}"
}

# Function to check the status and print in table format
check_status() {
    CMD=$1
    echo -e "\n$($CMD | column -t)"
}

# Function to print problematic pods
print_problematic_pods() {
    STATUSES=("0/1" "1/2" "0/2" "2/3" "1/3" "0/3")
    for STATUS in "${STATUSES[@]}"; do
        echo -e "\n===== Problematic Pods ($STATUS) ====="
        kubectl get po -A | grep -i "$STATUS" | column -t
    done
}

# Print header
print_header

# Print counts table
print_counts_table

# Detailed information
echo -e "\n===== All Namespace ====="
check_status "kubectl get ns"

echo -e "\n===== Node Status ====="
check_status "kubectl get node"

echo -e "\n===== Top Node ====="
check_status "kubectl top node"

echo -e "\n===== Pod All-Namespace ====="
check_status "kubectl get po -A"

echo -e "\n===== Problematic Pods ====="
print_problematic_pods

echo -e "\n===== pprod Pods ====="
NS="b2f05235-ba6b-47a5-9252-3a73f6ee83a5"
echo -e "\nTotal Pods in namespace ${NS}: $(kubectl get po -n ${NS} --no-headers | wc -l)"
check_status "kubectl get po -n ${NS}"

echo -e "\n===== sit1 Pods ====="
NS="22e933a8-3406-4e81-9382-c5d384ca510d"
echo -e "\nTotal Pods in namespace ${NS}: $(kubectl get po -n ${NS} --no-headers | wc -l)"
check_status "kubectl get po -n ${NS}"

echo -e "\n===== sit2 Pods ====="
NS="6bb35783-b673-4bc2-adfa-ed083265537b"
echo -e "\nTotal Pods in namespace ${NS}: $(kubectl get po -n ${NS} --no-headers | wc -l)"
check_status "kubectl get po -n ${NS}"

echo -e "\n===== sit3 Pods ====="
NS="5a0aca15-8b6c-487b-9a9d-9e92102165a1"
echo -e "\nTotal Pods in namespace ${NS}: $(kubectl get po -n ${NS} --no-headers | wc -l)"
check_status "kubectl get po -n ${NS}"

echo -e "\n===== dev Pods ====="
NS="31674166-4673-4755-999e-e5bd9a9df150"
echo -e "\nTotal Pods in namespace ${NS}: $(kubectl get po -n ${NS} --no-headers | wc -l)"
check_status "kubectl get po -n ${NS}"

echo -e "\n==== Ingress Status ===="
check_status "kubectl get ing -A | grep nginx"

echo -e "\n==== Problematic Pods Except Running ===="
check_status "kubectl get po -A | grep -v Running"

echo -e "\n====== CronJob ======"
check_status "kubectl get cj -A"

echo -e "\n===== Job ====="
check_status "kubectl get job -A"

echo -e "\n===== Deployment Status ====="
check_status "kubectl get deploy -A"
