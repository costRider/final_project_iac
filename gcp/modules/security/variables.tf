variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Target VPC network name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the whole VPC (for internal allow rules)"
  type        = string
}

variable "ssh_source_ranges" {
  description = "CIDR list allowed to access bastion via SSH"
  type        = list(string)
  default     = []
}
