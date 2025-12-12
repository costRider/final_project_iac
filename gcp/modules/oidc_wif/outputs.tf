output "github_wif_provider" {
  description = "GitHub Actions auth@v2에 넣을 workload_identity_provider 값"
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}

output "github_ci_sa_email" {
  description = "GitHub Actions auth@v2에 넣을 service_account 값"
  value       = google_service_account.github_ci.email
}