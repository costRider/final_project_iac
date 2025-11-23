###############################################
# Terraform Module: aws/env/modules/petclinic
#
# File: variables.tf 
#
# 설명:
#   - 목적: 개발환경 petclinic 사용 변수
#   - 구성요소: 외부 값들 불러서 petclinic에 사용
#
# 관리 정보:
#   - 최초 작성일: 2025-11-22
#   - 최근 수정일: 2025-11-23
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-23 / 관리용 헤더 템플릿 업데이트 / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################

variable "petclinic_db_endpoint"{
    description = "rds endpoint"
    type = string
}

variable "cluster_name" {
  description = "Cluter_name"
  type = string
}

variable "db_username"{
    description = "db username"
    type = string
}

variable "db_password"{
    description = "db password"
    type = string
}

variable "petclinic_ns" {
  description = "Petclinic Namespace"
  type = string
}

variable "petclinic_sa" {
  description = "Petclinic ServiceAccount"
  type = string
}

variable "aws_region" { type = string }