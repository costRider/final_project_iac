############################
#   outputs
############################

output "mgmt_sa_email" {
  value       = try(google_service_account.mgmt[0].email, null)
  description = "Mgmt instance SA email"
}

output "gke_node_sa_email" {
  value       = try(google_service_account.gke_node[0].email, null)
  description = "GKE node SA email"
}

output "gke_workload_sa_email"{
  value = try(google_service_account.gke_workload[0].email,null)
  description = "GKE workload SA email"
}