# This file declares calculated local values used across the network module.


###############################################
# Terraform Module: aws/env/dev/network
#
# File: locals.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 local
#   - 구성요소: 공통 네이밍 prefix
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

locals {
  region_code = coalesce(
    var.region_code,
     replace(var.aws_region, "-", "")
  )

  name_prefix = "${var.project_name}-aws-${var.environment}-${local.region_code}"

  az_code_map = { for az in var.azs : az => replace(az, var.aws_region, local.region_code) }
}
