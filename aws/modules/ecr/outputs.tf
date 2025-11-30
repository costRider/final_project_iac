###############################################
# Terraform Module: aws/env/modules/ecr
#
# File: outputs.tf 
#
# 설명:
#   - 목적: ECR output
#   - 구성요소: ECR 주소 output
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
#   - 2025-11-30 / 이미지 저장소 주소 output / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################

output "petclinic_ecr_arn"{
  description = "petclinic ARN"
  value = aws_ecr_repository.petclinic.arn
}

output "petclinic_ecr_repository_url" {
  description = "ECR repository URL for petclinic images"
  value       = aws_ecr_repository.petclinic.repository_url
}