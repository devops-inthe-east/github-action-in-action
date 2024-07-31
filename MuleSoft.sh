echo "***********************************"
echo "==========MULESOFT PREPROD============"
echo "***********************************"
echo "                                   "
echo "=====All Namespace====="

kubectl get ns

echo "=====Node Status====="

kubectl get node

echo "=====Node Count====="

kubectl get node | wc -l

echo "=====Top Node ====="

kubectl top node

echo "=====Pod All-Namespace====="

kubectl  get po -A

echo "=====Pod Count====="

kubectl  get po -A | wc -l


echo "===== Deployment count====="

kubectl get deploy -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | wc -l

echo

echo "=====Application Pods Count====="

kubectl get pods -A | grep -E '22e933a8-3406-4e81-9382-c5d384ca510d|31674166-4673-4755-999e-e5bd9a9df150|4d1953c8-cdd1-40c5-be37-d9d6ce6df0b9|5a0aca15-8b6c-487b-9a9d-9e92102165a1|6bb35783-b673-4bc2-adfa-ed083265537b|b2f05235-ba6b-47a5-9252-3a73f6ee83a5' | wc -l

echo

echo  "=====Problematic Pod 0/1========"

kubectl get po -A | grep -i 0/1

echo  "=====Problematic Pod 1/2========"

kubectl get po -A | grep -i 1/2

echo  "=====Problematic Pod 0/2========"

kubectl get po -A | grep -i 0/2

echo  "=====Problematic Pod 2/3========"

kubectl get po -A | grep -i 2/3

echo  "=====Problematic Pod 1/3========"

kubectl get po -A | grep -i 1/3

echo  "=====Problematic Pod 0/3========"

kubectl get po -A | grep -i 0/3

echo  "=====pprod Pods========"

kubectl get po -n b2f05235-ba6b-47a5-9252-3a73f6ee83a5

kubectl get po -n b2f05235-ba6b-47a5-9252-3a73f6ee83a5 | wc -l

echo  "=====sit1 Pods========"

kubectl get po -n 22e933a8-3406-4e81-9382-c5d384ca510d

kubectl get po -n 22e933a8-3406-4e81-9382-c5d384ca510d | wc -l

echo  "=====sit2 Pods========"

kubectl get po -n 6bb35783-b673-4bc2-adfa-ed083265537b

kubectl get po -n 6bb35783-b673-4bc2-adfa-ed083265537b | wc -l

echo  "=====sit3 Pods========"

kubectl get po -n 5a0aca15-8b6c-487b-9a9d-9e92102165a1

kubectl get po -n 5a0aca15-8b6c-487b-9a9d-9e92102165a1 | wc -l

echo  "=====dev Pods========"

kubectl get po -n 31674166-4673-4755-999e-e5bd9a9df150

kubectl get po -n 31674166-4673-4755-999e-e5bd9a9df150 | wc -l

echo "====ingress status======"

kubectl get ing -A | grep nginx | wc -l

echo  "====Problematic Pod Except Running======"

kubectl get po -A | grep -v Running


echo "======CronJob====="

kubectl get cj -A

echo "=====Job====="

kubectl get job -A

echo "=====Deployment status========="

kubectl get deploy -A
