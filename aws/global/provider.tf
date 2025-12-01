###############################################
# Terraform Module: aws/env/global/
#
# File: provider.tf 
#
# 설명:
#   - 목적: AWS 환경 공통 기준
#   - 구성요소: 프로바이더
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


provider "aws" {
  region = var.aws_region

  #root 하위의 모듈에서 생성하는 리소스에 Tag가 자동으로 붙는다.
  default_tags {
    tags = local.common_tags
  }

}

