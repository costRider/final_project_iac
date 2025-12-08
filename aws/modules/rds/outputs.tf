# This file provides outputs for the RDS module like endpoint and subnet identifiers.

###############################################
# Terraform Module: aws/env/modules/rds
#
# File: outputs.tf 
#
# 설명:
#   - 목적: 개발환경 DB
#   - 구성요소: DB Output 작성
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

output "petclinic_db_endpoint" {
  value = aws_db_instance.petclinic.endpoint
}

output "petclinic_db_port" {
  value = aws_db_instance.petclinic.port
}

output "petclinic_db_name" {
  value = aws_db_instance.petclinic.db_name
}

output "petclinic_db_username"{
  value = aws_db_instance.petclinic.username
}