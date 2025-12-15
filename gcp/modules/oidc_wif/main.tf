data "google_project" "this" {
  project_id = var.project_id
}

############################
# 1) Workload Identity Pool
############################
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "OIDC pool for GitHub Actions"
}

#############################################
# 2) Workload Identity Provider (GitHub OIDC)
#############################################
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub Actions Provider"
  description                        = "Trust GitHub OIDC tokens"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # GitHub 토큰 claim -> GCP attribute로 매핑
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"  # OWNER/REPO
    "attribute.actor"      = "assertion.actor"
    "attribute.ref"        = "assertion.ref"
  }

  # 특정 repo만 허용 (가장 중요)
  attribute_condition = "assertion.repository == '${var.github_owner}/${var.github_repo}'"
}

############################
# 3) CI용 GSA
############################
resource "google_service_account" "github_ci" {
  account_id   = "sa-github-ci"
  display_name = "GitHub Actions CI Service Account"
}

# GAR push 권한
resource "google_project_iam_member" "github_ci_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_ci.email}"
}

# WIF -> GSA Access Token 발급 허용 
resource "google_service_account_iam_member" "github_ci_token_creator" {
  service_account_id = google_service_account.github_ci.name
  role               = "roles/iam.serviceAccountTokenCreator"

  member = "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${var.github_repo}"
}


#####################################################
# 4) WIF -> GSA Impersonation 허용 (핵심 바인딩)
#####################################################
resource "google_service_account_iam_member" "github_ci_wif_user" {
  service_account_id = google_service_account.github_ci.name
  role               = "roles/iam.workloadIdentityUser"

  # principalSet: "이 Pool에서 온 토큰" 중 repository가 일치하는 것
  member = "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${var.github_repo}"
}