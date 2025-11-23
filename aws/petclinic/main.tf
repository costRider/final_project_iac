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

# 1단계(infra) state 가져오기
data "terraform_remote_state" "dev" {
  backend = "local"
   config = {
    path = "../env/dev/terraform.tfstate"  # ← dev root state 절대 또는 상대경로
  }
}

# 여기서 infra의 output 사용
locals {
  cluster_name          = data.terraform_remote_state.dev.outputs.cluster_name
  aws_region            = data.terraform_remote_state.dev.outputs.cluster_region
  petclinic_db_endpoint = data.terraform_remote_state.dev.outputs.petclinic_db_endpoint
  petclinic_ns = data.terraform_remote_state.dev.outputs.petclinic_ns
  petclinic_sa = data.terraform_remote_state.dev.outputs.petclinic_sa
  db_password = data.terraform_remote_state.dev.outputs.db_password 
  db_username = data.terraform_remote_state.dev.outputs.db_username
}

# 1) Namespace + SA (이미 .yaml로 있으면 그대로)
resource "kubernetes_manifest" "petclinic_ns" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-nsa.yaml.tftpl", {
      petclinic_ns            = locals.petclinic_ns
      petclinic_sa = locals.petclinic_sa
    })
  )
}

# 2) ConfigMap (RDS 정보 주입)
resource "kubernetes_manifest" "petclinic_configmap" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-configMap.yaml.tftpl", {
      petclinic_ns = locals.petclinic_ns
      petclinic_db_endpoint   = locals.petclinic_db_endpoint
    })
  )

  depends_on = [kubernetes_manifest.petclinic_ns]
}

# 3) Secret (DB 계정/패스워드)
resource "kubernetes_manifest" "petclinic_secret" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-secret.yaml.tftpl", {
      petclinic_ns  = locals.petclinic_ns
      db_username    = locals.db_username
      db_password    = locals.db_password
    })
  )

  depends_on = [kubernetes_manifest.petclinic_ns]
}

# 4) Deployment (envFrom으로 ConfigMap/Secret 사용)
resource "kubernetes_manifest" "petclinic_deployment" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-deployment-postgres.yaml.tftpl", {
      petclinic_ns            = locals.petclinic_ns
      petclinic_sa = locals.petclinic_sa
      db_profile           = "postgres" # SPRING_PROFILES_ACTIVE 넣으려면 이런 식으로
    })
  )

  depends_on = [
    kubernetes_manifest.petclinic_configmap,
    kubernetes_manifest.petclinic_secret,
  ]
}

# 5) Service / Ingress (ALB)
resource "kubernetes_manifest" "petclinic_service" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-service.yaml.tftpl", {
      petclinic_ns = locals.petclinic_ns
    })
  )

  depends_on = [kubernetes_manifest.petclinic_deployment]
}

resource "kubernetes_manifest" "petclinic_ingress" {
  manifest = yamldecode(
    templatefile("${path.module}/petclinic-ingress.yaml.tftpl", {
      petclinic_ns = locals.petclinic_ns
      //host      = var.petclinic_host # 필요하면
    })
  )

  depends_on = [kubernetes_manifest.petclinic_service]
}


