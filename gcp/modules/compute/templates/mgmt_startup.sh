#!/bin/bash
set -euo pipefail

#=============================#
# 0) Basic environment
#=============================#
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin"
export DEBIAN_FRONTEND=noninteractive
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

log() { echo "[mgmt-init] $*"; }

log "Bootstrapping management-server-gcp..."
hostnamectl set-hostname management-server-gcp || true

#=============================#
# 1) OS packages
#=============================#
apt-get update -y
apt-get install -y \
  ca-certificates gnupg lsb-release \
  unzip tar gzip \
  curl wget jq git

#=============================#
# 2) (Optional) AWS CLI v2
#=============================#
if ! command -v aws >/dev/null 2>&1; then
  log "Installing AWS CLI v2 (optional)..."
  cd /tmp
  curl -fsSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  unzip -q awscliv2.zip
  ./aws/install || true
  rm -rf aws awscliv2.zip
fi
aws --version >/dev/null 2>&1 || true

#=============================#
# 3) Google Cloud SDK + kubectl + GKE auth plugin
#=============================#
if ! command -v gcloud >/dev/null 2>&1; then
  log "Installing Google Cloud SDK..."
  if [ ! -f /usr/share/keyrings/cloud.google.gpg ]; then
    curl -fsS https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | gpg --dearmor \
      | tee /usr/share/keyrings/cloud.google.gpg >/dev/null
  fi

  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee /etc/apt/sources.list.d/google-cloud-sdk.list

  apt-get update -y
  apt-get install -y google-cloud-sdk
fi

# kubectl & auth plugin
apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin

gcloud version || true
kubectl version --client || true

#=============================#
# 4) Helm
#=============================#
if ! command -v helm >/dev/null 2>&1; then
  log "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
helm version || true

#=============================#
# 5) Terraform
#=============================#
if ! command -v terraform >/dev/null 2>&1; then
  log "Installing Terraform..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/hashicorp.list

  apt-get update -y

  if ! apt-get install -y terraform=${terraform_version}; then
    log "Terraform apt install failed. Fallback to direct download..."
    cd /tmp
    curl -fsSLo terraform.zip "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
    unzip -o terraform.zip
    mv terraform /usr/local/bin/terraform
    chmod +x /usr/local/bin/terraform
    rm -f terraform.zip
  fi
fi
terraform -version || true

#=============================#
# 6) kubeconfig (optional)
#=============================#
# Terraform provider 기반으로 k8s/helm을 붙일 거면 kubeconfig 없어도 되지만,
# mgmt에서 수동 kubectl/helm 디버깅을 하려면 있으면 편함.
mkdir -p /home/debian/.kube
chown -R debian:debian /home/debian/.kube

if ! grep -q "USE_GKE_GCLOUD_AUTH_PLUGIN" /home/debian/.bashrc 2>/dev/null; then
  echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/debian/.bashrc
fi
chown debian:debian /home/debian/.bashrc

# (실패해도 부팅 실패로 처리하지 않음)
sudo -u debian env HOME=/home/debian USE_GKE_GCLOUD_AUTH_PLUGIN=True \
  gcloud container clusters get-credentials "${cluster_name}" \
    --region "${region}" \
    --project "${project_id}" || true

chown -R debian:debian /home/debian/.kube
log "GCP MGMT node BASE INIT COMPLETE"

#=============================#
# 7) GitHub Self-Hosted Runner (GCP)
#=============================#

# Terraform inject values
GH_OWNER="${github_owner}"
GH_REPO="${github_repo}"
GCP_PROJECT_ID="${project_id}"
GHA_PAT_SECRET_NAME="${github_pat_secret_name}"
RUNNER_NAME="${runner_name}"
RUNNER_LABELS="${runner_labels}"
AUTO_DISPATCH_WORKFLOW="${auto_dispatch_workflow}"
DISPATCH_WORKFLOW_FILE="${dispatch_workflow_file}"

log "Installing GitHub self-hosted runner for $${GH_OWNER}/$${GH_REPO}"
log "Runner name: $${RUNNER_NAME}"
log "Runner labels: $${RUNNER_LABELS}"

id debian >/dev/null 2>&1 || { log "ERROR: debian user not found"; exit 1; }

# Dependencies for runner
apt-get install -y libicu-dev || true

# Ensure gcloud uses correct project
gcloud config set project "$GCP_PROJECT_ID" --quiet || true

# ---- IMPORTANT: Do NOT leak secrets in logs ----
# Temporarily disable xtrace if enabled elsewhere
set +x 2>/dev/null || true

# Read PAT from Secret Manager
GHA_PAT="$(gcloud secrets versions access latest \
  --secret="$GHA_PAT_SECRET_NAME" \
  --project="$GCP_PROJECT_ID")" || {
    log "ERROR: Failed to read GitHub PAT from Secret Manager ($${GHA_PAT_SECRET_NAME})."
    exit 0
  }

# Get runner registration token
RUNNER_TOKEN="$(curl -sX POST \
  -H "Authorization: Bearer $GHA_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$GH_OWNER/$GH_REPO/actions/runners/registration-token" \
  | jq -r .token)"

# Restore xtrace off 유지 (절대 켜지 말자: 토큰/패스워드 노출 위험)
# set -x  # intentionally NOT enabling

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" = "null" ]; then
  log "ERROR: Failed to create runner registration token."
  exit 0
fi

# Get latest runner version
LATEST_TAG="$(curl -s \
  -H "Authorization: Bearer $GHA_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/actions/runner/releases/latest" \
  | jq -r '.tag_name')"

RUNNER_VERSION="$(echo "$LATEST_TAG" | sed 's/^v//')"
if [ -z "$RUNNER_VERSION" ] || [ "$RUNNER_VERSION" = "null" ]; then
  RUNNER_VERSION="2.319.1"
fi
log "Detected runner version: $RUNNER_VERSION"

RUNNER_DIR="/opt/github-runner"
mkdir -p "$RUNNER_DIR"
chmod 755 "$RUNNER_DIR"

# Download runner if not installed
if [ ! -f "$RUNNER_DIR/config.sh" ]; then
  log "Downloading GitHub Actions runner..."
  cd "$RUNNER_DIR"
  curl -L -o actions-runner.tar.gz \
    "https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz"
  tar xzf actions-runner.tar.gz
  rm -f actions-runner.tar.gz
fi

chown -R debian:debian "$RUNNER_DIR"

# Configure runner
sudo -u debian bash -lc "
set -euo pipefail
cd '$RUNNER_DIR'
./config.sh \
  --url 'https://github.com/$GH_OWNER/$GH_REPO' \
  --token '$RUNNER_TOKEN' \
  --name '$RUNNER_NAME' \
  --labels '$RUNNER_LABELS' \
  --unattended \
  --replace
"

# Install & start as service
cd "$RUNNER_DIR"
./svc.sh install || true
./svc.sh start || true
./svc.sh status || true

log "GCP MGMT node + GitHub Runner INIT COMPLETE"

#=============================#
# 8) Optional: Dispatch workflow
#=============================#
if [ "$AUTO_DISPATCH_WORKFLOW" = "true" ]; then
  log "Dispatching workflow: $DISPATCH_WORKFLOW_FILE"
  curl -sX POST \
    -H "Authorization: Bearer $GHA_PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$GH_OWNER/$GH_REPO/actions/workflows/$DISPATCH_WORKFLOW_FILE/dispatches" \
    -d '{"ref":"main"}' || true
fi

log "Startup script completed."
