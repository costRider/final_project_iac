# Proejct 명(고정 되어있음)
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

# VPC 명
variable "network_name" {
  description = "VPC name"
  type        = string
}

#public(bastion), private{mgmt, app(gke), db}
variable "subnets" {
  description = "Subnets to create"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    role          = string # "mgmt", "app", "db" 등 태그/설명용
  }))
}

# NAT 환경을 Enable 하는 trigger 
variable "enable_nat" {
  description = "Enable Cloud NAT for all subnets"
  type        = bool
  default     = true
}
