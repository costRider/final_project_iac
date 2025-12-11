############################
#   main.tf
############################

############################
# 1) Mgmt VM용 Service Account
############################
resource "google_service_account" "mgmt" {
  count        = var.enable_mgmt_sa ? 1 : 0
  account_id   = "sa-mgmt"
  display_name = "Mgmt Instance Service Account"
}

# Mgmt SA에 최소 권한 (로그/모니터링 + 나중에 SSH용 OS Login 등)
resource "google_project_iam_member" "mgmt_logging" {
  count   = var.enable_mgmt_sa ? 1 : 0
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.mgmt[0].email}"
}

resource "google_project_iam_member" "mgmt_monitoring" {
  count   = var.enable_mgmt_sa ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.mgmt[0].email}"
}

# 1-2. 인프라 관리용 **Editor/Admin급 권한** (DEV/POC라서 과감 버전)
# 👉 좀 더 보수적으로 가려면 owner 대신 editor 써도 됨.
resource "google_project_iam_member" "mgmt_project_admin" {
  count   = var.enable_mgmt_sa ? 1 : 0
  project = var.project_id
  role    = "roles/editor" # 또는 "roles/owner" (진짜 풀관리자)
  member  = "serviceAccount:${google_service_account.mgmt[0].email}"
}

#GCP 관리를 위한 Container Admin 권한도 부여
resource "google_project_iam_member" "mgmt_container_admin" {
  count   = var.enable_mgmt_sa ? 1 : 0
  project = var.project_id
  role    = "roles/container.admin" # 또는 "roles/owner" (진짜 풀관리자)
  member  = "serviceAccount:${google_service_account.mgmt[0].email}"
}

resource "google_storage_bucket_iam_member" "mgmt_tf_state" {
  bucket = "final-terraform-gcs"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.mgmt[0].email}"
}

############################
# 2) GKE Node용 Service Account
############################
resource "google_service_account" "gke_node" {
  count        = var.enable_gke_sa ? 1 : 0
  account_id   = "sa-gke-node"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "gke_node_logging" {
  count   = var.enable_gke_sa ? 1 : 0
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node[0].email}"
}

resource "google_project_iam_member" "gke_node_monitoring" {
  count   = var.enable_gke_sa ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node[0].email}"
}

############################
# 3) GKE Workload용 GSA (나중에 Workload Identity 연결)
############################
resource "google_service_account" "gke_workload" {
  count        = var.enable_gke_sa ? 1 : 0
  account_id   = "sa-gke-workload"
  display_name = "GKE Workload Service Account"
}

# 아직은 큰 권한 안 줌. 나중에 필요시:
# - roles/secretmanager.secretAccessor
# - roles/cloudsql.client
# 같은 걸 여기에 incrementally 추가하면 됨.