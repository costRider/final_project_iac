###############################################
# Terraform Module: aws/env/modules/ecr
#
# File: main.tf 
#
# 설명:
#   - 목적: ECR 설정
#   - 구성요소: repo 작성 
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
#   - 2025-11-30 / 이미지 저장소 작성 / 작성자: LMK 
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################

resource "aws_ecr_repository" "petclinic" {
  name = var.ecr_petclinic_repo_name # 기본값: eks/petclinic

  image_tag_mutability = "MUTABLE"

  #삭제 시 내용도 같이 강제 삭제
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
/*
  lifecycle_policy {
    # (옵션) 오래된 태그 자동 정리 정책 추가하고 싶으면 여기에 JSON
    # 아래는 예시 형태 설명만, 실제 정책은 나중 단계에서 다듬어도 됨
    # text = file("${path.module}/ecr-lifecycle-petclinic.json")
  }
*/
  tags = {
    Project = "petclinic"
    Env     = "dev"
  }
}