###############################################
# Terraform Module: aws/env/global/
#
# File: variables.tf 
#
# 설명:
#   - 목적: AWS 환경 공통 기준
#   - 구성요소: 변수
#
# 관리 정보:
#   - 최초 작성일: 2025-11-22
#   - 최근 수정일: 2025-11-22
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-22 / 관리용 헤더 템플릿 업데이트 / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################

variable "aws_region" {
  description = "리소스를 생성할 AWS 리전(예: ap-northeast-2)"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 명 prefix(태그/이름에 사용)"
  type        = string
  default     = "persoanl-eks"
}

variable "cluster_name" {
  description = "EKS 클러스터 이름(서브넷 태그에 사용)"
  type        = string
  default     = "k8s-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR대역(추후 서브넷 쪼개기 기준)"
  type        = string
  default     = "10.10.0.0/16"
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

variable "azs" {
  description = "사용할 AZ목록(퍼블릭/프라이빗 서브넷 매칭에 사용)"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
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

##############
# 태깅구분 하기
##############

variable "environment" {
  description = "환경구분 (dev,stg,prod 등)"
  type        = string
}

variable "owner" {
  description = "리소스 소유자"
  type        = string
}

variable "cost_center" {
  description = "비용 주체"
  type = string
}