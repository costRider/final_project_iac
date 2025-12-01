# This file creates public and private subnets for the shared network module.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: subnets.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 서브넷
#   - 구성요소: public,mgmt,worker,db
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

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-net-subnet-pub-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  })
}

resource "aws_subnet" "mgmt" {
  count = length(var.private_mgmt_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_mgmt_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-mgmt-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

resource "aws_subnet" "worker" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-app-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

resource "aws_subnet" "db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-db-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}
