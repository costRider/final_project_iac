variable "project_id" { type = string }

variable "github_owner" {
  type        = string
  description = "GitHub org/user (e.g. costRider)"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (e.g. spring-petclinic-readonly)"
}

variable "wif_pool_id" {
  type        = string
  default     = "github-pool"
  description = "Workload Identity Pool ID"
}

variable "wif_provider_id" {
  type        = string
  default     = "github-provider"
  description = "Workload Identity Provider ID"
}