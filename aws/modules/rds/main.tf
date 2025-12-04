# This module builds the Amazon RDS database resources and supporting networking configuration.
###############################################
# Terraform Module: aws/env/modules/rds
#
# File: main.tf 
#
# 설명:
#   - 목적: 개발환경 DB
#   - 구성요소: DB 구성
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

#############################
# RDS 생성
#############################

resource "aws_db_subnet_group" "petclinic" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

#인스턴스 생성
resource "aws_db_instance" "petclinic" {
  identifier            = "${var.project_name}-${var.environment}-postgres"
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "postgres"
  # engine_version          = "16.3"          # 필요시 조정
  instance_class          = "db.t3.micro"   # 실습이면 이 정도
  db_name                 = "petclinic"
  username                = "petclinic"
  
  manage_master_user_password = true
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_arn

  port                    = 5432

  db_subnet_group_name   = aws_db_subnet_group.petclinic.name
  vpc_security_group_ids  = [aws_security_group.db.id]

  multi_az                = false           # 필요시 true
  publicly_accessible     = false
  skip_final_snapshot     = true

  backup_retention_period = 1

  deletion_protection     = false

   tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds"
  })
}

#############################
# RDS 생성 종료
#############################

#############################
# RDS Security Group 생성 
#############################

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg-db-01"
  description = "DB security group"
  vpc_id      =  var.vpc_id 

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-db-sg-db-01"
  })
}

resource "aws_security_group_rule" "db_ingress_from_Node" {
  type              = "ingress"
  description       = "Allow db inbound traffic from node"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = var.cluster_sg_id
  security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
}

#############################
# RDS Security Group 생성 종료
#############################
