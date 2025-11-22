# This file enumerates variable definitions for configuring the network module.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: variables.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 변수
#   - 구성요소: variables 변수
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

variable "project_name" {
  description = "프로젝트 명 prefix(태그/이름에 사용)"
  type        = string
}

variable "environment" {
  description = "환경 구분(dev/stg/prd)"
  type        = string
}

variable "aws_region" {
  description = "리소스를 생성할 AWS 리전"
  type        = string
}

variable "region_code" {
  description = "네이밍에 사용할 리전 코드(apne2 등). 제공되지 않으면 aws_region에서 추출"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 대역"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록"
  type        = list(string)
}

variable "private_mgmt_subnet_cidrs" {
  description = "관리용 프라이빗 서브넷 CIDR 목록"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "애플리케이션(노드) 프라이빗 서브넷 CIDR 목록"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "DB 프라이빗 서브넷 CIDR 목록"
  type        = list(string)
}

variable "azs" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "my_ip_cidr" {
  description = "SSH 허용용 개인 IP CIDR"
  type        = string
}

variable "bastion_ami_id" {
  description = "베스천 AMI ID"
  type        = string
}

variable "mgmt_ami_id" {
  description = "관리용 EC2 AMI ID"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH 키페어 이름"
  type        = string
}

variable "instance_type_bastion" {
  description = "베스천 인스턴스 타입"
  type        = string
}

variable "instance_type_mgmt" {
  description = "관리용 인스턴스 타입"
  type        = string
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}
