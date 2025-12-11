locals {
  common_tags = {
    Project     = var.project_id
    Environment = var.environment
    Owner       = var.owner

    ManagedBy  = "Terraform"
    cost_center = var.cost_center
  }
}