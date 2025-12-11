variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (e.g., asia-northeast3)"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
}

variable "network_name" {
  type        = string
  description = "VPC network name"
}

variable "subnet_app_name" {
  type        = string
  description = "Subnetwork name for GKE nodes (app subnet)"
}

variable "gke_node_sa_email" {
  type        = string
  description = "Service Account email used by GKE nodes"
}

variable "gke_zones" {
  type        = list(string)
  description = "List of zones for regional GKE (node_locations)"
}

variable "min_node_count" {
  type        = number
  default     = 1
}

variable "max_node_count" {
  type        = number
  default     = 3
}

variable "node_machine_type" {
  type        = string
  default     = "e2-medium"
}