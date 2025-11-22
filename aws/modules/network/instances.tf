# This file provisions bastion and management instances within the network module.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: instance.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 인스턴스
#   - 구성요소: bastion 및 mgmt 인스턴스 
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

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id
  instance_type               = var.instance_type_bastion
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-bastion-01"
  })
}

####################################
# 각 전체 리소스관리를 담당할 ec2 
####################################
resource "aws_instance" "mgmt" {
  ami                    = var.mgmt_ami_id
  instance_type          = var.instance_type_mgmt
  subnet_id              = aws_subnet.mgmt[0].id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.mgmt.id]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-mgmt-admin-01"
  })
}
