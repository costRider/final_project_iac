#!/bin/bash
set -e

CLUSTER_NAME="$1"
AWS_REGION="$2"

echo "[LBC] update-kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

echo "[LBC] helm repo add..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "[LBC] installing aws-load-balancer-controller..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace "kube-system" \
  --create-namespace \
  --set clusterName="$CLUSTER_NAME" \
  --set region="$AWS_REGION" \
  --set serviceAccount.create=true \
  --set serviceAccount.name="aws-load-balancer-controller"

echo "[LBC] done."
