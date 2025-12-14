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
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    role          = optional(string)

    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

# NAT 환경을 Enable 하는 trigger 
variable "enable_nat" {
  description = "Enable Cloud NAT for all subnets"
  type        = bool
  default     = true
}
