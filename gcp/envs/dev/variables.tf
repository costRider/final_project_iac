variable "project_id"{
    description = "프로젝트 ID"
    type = string
}

variable "gcp_zone" {
  description = "존 설정"
  type = string
}

variable "environment" {
  description = "환경 Dev/Prd/Stg"
  type = string
}

variable "gcp_region" {
  description = "Region"
  type = string
}

variable "owner"{
    description = "리소스 소유자"
    type = string
}

variable "cost_center"{
    description = "비용주체"
    type = string
}

variable "cluster_name" {
  description = "GKE 클러스터 이름"
  type        = string
  default     = "k8s-gke"
}

variable "vpc_cidr" {
  description = "VPC CIDR대역(추후 서브넷 쪼개기 기준)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록(각 AZ용)"
  type        = list(string)
}

variable "mgmt_subnet_cidrs" {
  description = "mgmt 서브넷 CIDR 목록(각 AZ용)"
  type        = list(string)
}

variable "worker_subnet_cidrs" {
  description = "worker 서브넷- CIDR 목록(각 AZ용)"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "db 서브넷 CIDR 목록(각 AZ용)"
  type        = list(string)
}


variable "my_ip_cidr" {
  description = "로컬 공인 IP(SSH용)"
  type        = string
}

variable "bastion_ami_id" {
  description = "Bastion EC2 AMI ID - Amazon Linux 2023 kernel-6.12 AMI"
  type        = string
}

variable "mgmt_ami_id" {
  description = "Bastion EC2 AMI ID - Amazon Linux 2023 kernel-6.12 AMI"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH 키페어"
  type        = string
}

variable "instance_type_bastion" {
  description = "bastion 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_mgmt" {
  description = "mgmt 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

variable "cluster_version" {
  description = "EKS 버전(예: 1.30)"
  type        = string
}

variable "node_instance_types_default" {
  description = "EKS default 노드 인스턴스 타입 목록"
  type        = list(string)
}

variable "node_instance_types_app" {
  description = "EKS app 노드 인스턴스 타입 목록"
  type        = list(string)
}

variable "node_instance_types_obs" {
  description = "EKS obs 노드 인스턴스 타입 목록"
  type        = list(string)
}

variable "node_capacity_type" {
  description = "ON_DEMAND 또는 SPOT"
  type        = string
}

variable "node_desired_size" {
  description = "NodeGroup desired"
  type        = number
}

variable "node_min_size" {
  description = "NodeGroup Min"
  type        = number
}

variable "node_max_size" {
  description = "NodeGroup Max"
  type        = number
}

variable "node_disk_siez" {
  description = "NodeGroup 루트 디스크 크기"
  type        = number
}

