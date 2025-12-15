# This file specifies the input variables for configuring the RDS module resources.

###############################################
# Terraform Module: aws/env/modules/rds
#
# File: variables.tf 
#
# 설명:
#   - 목적: 개발환경 DB
#   - 구성요소: DB 용 변수
#
# 관리 정보:
#   - 최초 작성일: 2025-11-23
#   - 최근 수정일: 2025-11-23
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-23 / rds 생성용 작성 / 작성자: LMK 
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

variable "azs" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "vpc_id"          { type = string }
variable "db_subnet_ids"   { type = list(string) } # PRIVATE DB Subnets

variable "cluster_sg_id" {  type = string }

variable "vpn_allowed_cidrs" {
  description = "CIDRs allowed to access PostgreSQL via S2S VPN (e.g., GCP subnet ranges)"
  type        = list(string)
  default     = []
}