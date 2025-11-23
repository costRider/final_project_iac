###############################################
# Terraform Module: aws/env/modules/petclinic
#
# File: main.tf 
#
# 설명:
#   - 목적: 개발환경 petclinic setup
#   - 구성요소: 각 요소들 모아서 실행
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

resource "null_resource" "deploy_petclinic" {
  triggers = {
    db_endpoint  = var.petclinic_db_endpoint
    db_name      = var.db_username
    db_pass  = var.db_password
    pod_role_arn = var.pod_role_arn
  }

  provisioner "local-exec" {
    command = <<EOT
      ./scripts/deploy_petclinic.sh \
        --db-endpoint=${var.petclinic_db_endpoint} \
        --db-name=${var.db_username} \
        --db-pass=${var.db_password}
    EOT
  }
}
