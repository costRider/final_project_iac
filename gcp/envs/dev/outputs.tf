output "bastion_external_ip" {
  value = module.compute.bastion_external_ip
}

output "mgmt_internal_ip" {
  value = module.compute.mgmt_internal_ip
}

output "repo_urls" {
  value = module.artifact_registry.repo_urls
}

output "github_wif_provider" {
  value = module.oidc_wif.github_wif_provider
}

output "github_ci_sa_email" {
  value = module.oidc_wif.github_ci_sa_email
}

output "cluster_name" {
  value = module.gke.cluster_name
}

output "gke_workload_sa_email" {
  value = module.iam.gke_workload_sa_email
}

output "project_id"{
  value = var.project_id
}

output "region"{
  value = var.gcp_region
}