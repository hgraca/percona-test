#!/usr/bin/env bash

NAMESPACE='test-percona'

echo "----- ----- ----- ----- ----- -----"
echo "----- CLUSTER OBJECTS IN NAMESPACE '${NAMESPACE}'"
echo "----- ----- ----- ----- ----- -----"
echo ""
echo "PERCONA CLUSTERS"
kubectl get pxc --namespace "${NAMESPACE}" -o wide
echo ""
echo "DEPLOYMENTS"
kubectl get deployments --namespace "${NAMESPACE}" -o wide
echo ""
echo "REPLICA SETS"
kubectl get replicasets --namespace "${NAMESPACE}" -o wide
echo ""
echo "STATEFUL SETS"
kubectl get statefulset --namespace "${NAMESPACE}" -o wide
echo ""
echo "SERVICES"
kubectl get services --namespace "${NAMESPACE}" -o wide
echo ""
echo "PODS"
kubectl get pods --namespace "${NAMESPACE}" -o wide
echo ""
echo "PERSISTENT VOLUME CLAIMS"
kubectl get pvc --namespace "${NAMESPACE}" -o wide
echo ""
echo "PERSISTENT VOLUMES"
kubectl get pv --namespace "${NAMESPACE}" -o wide
echo ""
echo "SECRETS"
kubectl get secrets --namespace "${NAMESPACE}" -o wide
echo "----- ----- ----- ----- ----- -----"
