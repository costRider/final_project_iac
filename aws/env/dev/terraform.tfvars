# This file supplies dev environment variable values for the ap-northeast-2 deployment.

###############################################
# Terraform Module: aws/env/dev/
#
# File: terraform.tfvars 
#
# 설명:
#   - 목적: 개발환경 root 변수값 할당
#   - 구성요소: 공통 태그, CIDR, AMI, 인스턴스 타입 및 기타
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

project_name = "finalproj"
environment  = "dev"
aws_region   = "ap-northeast-2"
region_code  = "apne2"

cluster_name    = "k8s-eks"
cluster_version = "1.33"

vpc_cidr = "10.10.0.0/16"

# CIDR Schema에 맞추어 작성 10.{AWS/dev}.{sub/zone}.0/24
public_subnet_cidrs       = ["10.10.10.0/24", "10.10.12.0/24"]
private_mgmt_subnet_cidrs = ["10.10.20.0/24", "10.10.22.0/24"]
private_app_subnet_cidrs  = ["10.10.30.0/24", "10.10.32.0/24"]
private_db_subnet_cidrs   = ["10.10.40.0/24", "10.10.42.0/24"]

# CIDR 구성에 맞추어 a,c 로 구성(0,2)
azs = ["ap-northeast-2a", "ap-northeast-2c"]

my_ip_cidr   = "180.70.43.251/32"
ssh_key_name = "academyKey"

bastion_ami_id        = "ami-0aa02302a11ea5190"
mgmt_ami_id           = "ami-0aa02302a11ea5190"
instance_type_bastion = "t3.micro"
instance_type_mgmt    = "t3.small"

node_instance_types_default = ["t3.small"]
node_instance_types_app     = ["t3.small"]
node_instance_types_obs     = ["t3.medium"]

node_capacity_type = "ON_DEMAND"
node_desired_size  = 2
node_disk_size     = 30
node_min_size      = 1
node_max_size      = 4

owner       = "mklee"
cost_center = "petclinic-dev"

db_username  = "petclinic"
db_password  = "poweradmin!"
petclinic_ns = "petclinic-ns"
petclinic_sa = "petclinic-sa"
