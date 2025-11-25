###############################################
# Terraform Module: aws/env/modules/petclinic
#
# File: locals.tf 
#
# 설명:
#   - 목적: 개발환경 petclinic setup
#   - 구성요소: 각 요소들 모아서 실행
#
# 관리 정보:
#   - 최초 작성일: 2025-11-22
#   - 최근 수정일: 2025-11-25
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-25 / main.tf 에서 locals.tf로 분리 / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################
# 1단계(infra) state 가져오기
data "terraform_remote_state" "dev" {
  backend = "local"
  config = {
    path = "../env/dev/terraform.tfstate" # ← dev root state 절대 또는 상대경로
  }
}

# 여기서 infra의 output 사용
locals {
  cluster_name          = data.terraform_remote_state.dev.outputs.cluster_name
  aws_region            = data.terraform_remote_state.dev.outputs.cluster_region
  petclinic_db_endpoint = data.terraform_remote_state.dev.outputs.petclinic_db_endpoint
  petclinic_ns          = data.terraform_remote_state.dev.outputs.petclinic_ns
  petclinic_sa          = data.terraform_remote_state.dev.outputs.petclinic_sa
  db_password           = data.terraform_remote_state.dev.outputs.db_password
  db_username           = data.terraform_remote_state.dev.outputs.db_username
}