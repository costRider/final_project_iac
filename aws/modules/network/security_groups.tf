# This file configures security groups and rules for the shared network module.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: security_groups.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 보안그룹
#   - 구성요소: bastion,mgmt,node(worker),db
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

resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-net-sg-bastion-01"
  description = "Bastion SSH"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-sg-bastion-01"
  })
}

resource "aws_security_group" "mgmt" {
  name        = "${local.name_prefix}-mgmt-sg-control-01"
  description = "SSH From bastion to MGMT"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-mgmt-sg-control-01"
  })
}

#############################################
# 2022-11-22  - LMK 작성
# 보안그룹 룰 적용
# 1. bastion - Source:MyIP/INBOUND(22), OUTBOUND(ALL)
# 2. mgmt - Source:Bastion/INBOUND(22), OUTBOUND(ALL)
#############################################

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  description       = "Allow SSH From MyIP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.my_ip_cidrs
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "mgmt_ingress_ssh_from_bastion" {
  type                     = "ingress"
  description              = "Allow SSH from bastion SG"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.mgmt.id
}

resource "aws_security_group_rule" "mgmt_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mgmt.id
}

