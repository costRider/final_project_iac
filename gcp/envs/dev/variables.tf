variable "project_id" {
  description = "프로젝트 ID"
  type        = string
  default     = "kdt2-final-project-t2"
}

variable "gcp_zone" {
  description = "존 설정"
  type        = list(string)
  default     = ["asia-northeast3-a", "asia-northeast3-c"]
}

variable "environment" {
  description = "환경 Dev/Prd/Stg"
  type        = string
}

variable "gcp_region" {
  description = "Region"
  type        = string
  default     = "asia-northeast3"
}

variable "owner" {
  description = "리소스 소유자"
  type        = string
  default     = "mklee"
}

variable "cost_center" {
  description = "비용주체"
  type        = string
}

variable "cluster_name" {
  description = "GKE 클러스터 이름"
  type        = string
  default     = "k8s-gke"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.20.0.0/16"
}

variable "ssh_source_ranges" {
  type        = list(string)
  description = "CIDRs allowed to SSH to bastion"
  default     = ["1.223.214.165/32"] # 나중에 tfvars에서 교체
}

variable "subnets" {
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    role          = string
  }))
}

variable "network_name" {
  type = string
}

variable "bastion_ssh_public_key" {
  type = string
}

variable "k8s_namespace" {
  type = string
}

variable "k8s_service_account" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "node_machine_type" {
  type = string
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}