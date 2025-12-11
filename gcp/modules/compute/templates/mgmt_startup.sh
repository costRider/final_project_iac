#!/bin/bash
set -euxo pipefail

#-------------#
# Base Setup
#-------------#

export PATH=$PATH:/usr/local/bin:/usr/bin:/bin
export DEBIAN_FRONTEND=noninteractive
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# 호스트명 설정
hostnamectl set-hostname management-server-gcp || true

# 패키지 업데이트 + 기본 유틸 설치
apt-get update -y
apt-get install -y \
  ca-certificates \
  gnupg \
  lsb-release \
  unzip \
  tar \
  gzip \
  curl \
  wget \
  jq \
  git

#-------------#
# Install AWS CLI v2
#-------------#
cd /tmp
curl -fsSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q awscliv2.zip
./aws/install || true
rm -rf aws awscliv2.zip

aws --version || true

#-------------#
# Install Google Cloud SDK + kubectl + GKE auth plugin
#-------------#
if [ ! -f /usr/share/keyrings/cloud.google.gpg ]; then
  curl -fsS https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/cloud.google.gpg >/dev/null
fi

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
  | tee /etc/apt/sources.list.d/google-cloud-sdk.list

apt-get update -y

apt-get install -y \
  google-cloud-sdk \
  kubectl \
  google-cloud-sdk-gke-gcloud-auth-plugin

gcloud version || true
kubectl version --client || true

#-------------#
# Install Helm
#-------------#
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  | bash

helm version || true

#-------------#
# Install Terraform
#-------------#
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update -y

if ! apt-get install -y terraform=${terraform_version}; then
  echo "HashiCorp repo 기반 Terraform 설치 실패, 수동 설치로 fallback"
  cd /tmp
  curl -fsSLo terraform.zip \
    "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
  unzip -o terraform.zip
  mv terraform /usr/local/bin/terraform
  chmod +x /usr/local/bin/terraform
  rm -f terraform.zip
fi

terraform -version || true

#-------------#
# Generate kubeconfig for mgmt VM (GKE admin용)
#-------------#

# debian 유저 홈에 kube 디렉토리 준비
mkdir -p /home/debian/.kube
chown -R debian:debian /home/debian/.kube

# debian 쉘에서 GKE auth plugin 사용하도록 환경변수 설정
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/debian/.bashrc
chown debian:debian /home/debian/.bashrc

# kubeconfig 생성을 debian 유저로 실행 (HOME 명시)
sudo -u debian env HOME=/home/debian USE_GKE_GCLOUD_AUTH_PLUGIN=True \
  gcloud container clusters get-credentials "${cluster_name}" \
    --region "${region}" \
    --project "${project_id}"

# 권한 정리
chown -R debian:debian /home/debian/.kube

echo "GCP MGMT node BASE INIT COMPLETE"
