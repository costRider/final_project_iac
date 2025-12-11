variable "project_id" {
  type = string
}

variable "gsa_email" {
  type        = string
  description = "GCP Service Account email (예: sa-gke-workload@...)"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace (예: petclinic)"
}

variable "k8s_service_account" {
  type        = string
  description = "Kubernetes ServiceAccount name (예: petclinic-sa)"
}
