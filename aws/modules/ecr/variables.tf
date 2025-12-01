###############################################
# Terraform Module: aws/env/modules/ecr
#
# File: variables.tf 
#
# 설명:
#   - 목적: ECR 구성용 변수값
#   - 구성요소: ecr name 값 
#
# 관리 정보:
#   - 최초 작성일: 2025-11-30
#   - 최근 수정일: 2025-11-30
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-30 / ecr 네이밍용 변수 값 작성 / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################


variable "ecr_petclinic_repo_name" {
  description = "ECR repository name for petclinic images"
  type        = string
  default     = "eks/petclinic"
}
