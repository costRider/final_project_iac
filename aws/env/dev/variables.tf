# This file lists variable declarations for the dev environment stack.
###############################################
# Terraform Module: aws/env/dev/
#
# File: variables.tf 
#
# 설명:
#   - 목적: 개발환경 root 변수선언
#   - 구성요소: 공통 태그, CIDR, AMI, 인스턴스 타입 및 기타
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

variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "region_code" { type = string }
variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_mgmt_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
variable "my_ip_cidr" { type = string }
variable "bastion_ami_id" { type = string }
variable "mgmt_ami_id" { type = string }
variable "ssh_key_name" { type = string }
variable "instance_type_bastion" { type = string }
variable "instance_type_mgmt" { type = string }
variable "node_instance_types_default" { type = list(string) }
variable "node_instance_types_app" { type = list(string) }
variable "node_instance_types_obs" { type = list(string) }
variable "node_capacity_type" { type = string }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "node_disk_size" { type = number }
variable "owner" { type = string }
variable "cost_center" { type = string }
variable "db_password" { type = string }
variable "db_username" { type = string }
variable "petclinic_sa" { type = string }
variable "petclinic_ns" { type = string }