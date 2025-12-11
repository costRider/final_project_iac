############################################
# Workload Identity Binding
#  GSA ↔ KSA
############################################

# 1) GSA 측에 "이 KSA가 나를 사용해도 됨" 권한 부여
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.gsa_email}"
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}

# 2) 나중에 KSA에 붙일 annotation 값도 같이 output 하도록
output "ksa_annotation" {
  value = "iam.gke.io/gcp-service-account=${var.gsa_email}"
}
