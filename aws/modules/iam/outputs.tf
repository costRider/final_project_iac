# This file publishes IAM-related outputs such as role ARNs from the module.

###############################################
# Terraform Module: aws/env/modules/iam
#
# File: outputs.tf 
#
# 설명:
#   - 목적: 개발환경 IAM에서 작성한 내용 Output
#   - 구성요소: MGMT역할, 프로필
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

output "mgmt_role_arn"{
  description = "mgmt 권한 Role arn"
  value = aws_iam_role.mgmt.arn
}

output "mgmt_profile_arn" {
  description = "MGMT EC2에 할당할 EKS 컨트롤 프로필 ARN"
  value = aws_iam_instance_profile.mgmt.arn
}

output "mgmt_profile_name" {
  description = "MGMT EC2에 할당할 EKS 컨트롤 프로필 NAME"
  value = aws_iam_instance_profile.mgmt.name
}

