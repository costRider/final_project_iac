# This environment file assembles network and EKS modules for the ap-northeast-2 dev stack.

###############################################
# Terraform Module: aws/env/dev/
#
# File: main.tf 
#
# 설명:
#   - 목적: 개발환경 root main
#   - 구성요소: 테라폼 구성 적용
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

module "network" {
  source = "../../modules/network"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  region_code               = var.region_code
  cluster_name              = var.cluster_name
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_mgmt_subnet_cidrs = var.private_mgmt_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_db_subnet_cidrs   = var.private_db_subnet_cidrs
  azs                       = var.azs
  my_ip_cidr                = var.my_ip_cidr
  bastion_ami_id            = var.bastion_ami_id
  mgmt_ami_id               = var.mgmt_ami_id
  ssh_key_name              = var.ssh_key_name
  instance_type_bastion     = var.instance_type_bastion
  instance_type_mgmt        = var.instance_type_mgmt
  common_tags               = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  project_name    = var.project_name
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id            = module.network.vpc_id
  worker_subnet_ids = module.network.worker_subnet_ids
  node_sg_id        = module.network.node_sg_id
  mgmt_sg_id        = module.network.mgmt_sg_id

  cluster_additional_sg_ids = []

  node_instance_types_default = var.node_instance_types_default
  node_instance_types_app     = var.node_instance_types_app
  node_instance_types_obs     = var.node_instance_types_obs

  node_capacity_type = var.node_capacity_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_disk_size     = var.node_disk_size

  common_tags = local.common_tags
}
