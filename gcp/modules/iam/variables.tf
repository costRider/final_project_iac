############################
#   variable 
############################

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "enable_mgmt_sa" {
  type        = bool
  default     = true
}

variable "enable_gke_sa" {
  type        = bool
  default     = true
}