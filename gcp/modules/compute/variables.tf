variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Region where instances will be created"
}

variable "zone" {
  type        = string
  description = "Zone for bastion/mgmt instances"
}

variable "network_name" {
  type        = string
  description = "VPC network name"
}

variable "subnets" {
  description = "Subnet map from network module"
  type = map(object({
    name   = string
    region = string
    cidr   = string
    self   = string
  }))
}

variable "bastion_public_key" {
  description = "SSH public key used for bastion VM"
  type        = string
}

variable "mgmt_sa_email" {
  description = "Service Account email for mgmt VM"
  type        = string
}

variable "terraform_version" {
  type    = string
  default = "1.14.0"
}

variable "gke_cluster_name" {
  type = string
}

variable "github_owner"{
  type = string
}

variable "github_repo"{
  type = string
}

variable "github_pat_secret_name"{
  type = string
}
