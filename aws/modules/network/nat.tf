# This file manages NAT gateway resources for the shared network module.


###############################################
# Terraform Module: aws/env/dev/network
#
# File: nat.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 NAT
#   - 구성요소: nat gw , eip 
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

resource "aws_eip" "nat" {
  count  = length(var.azs)
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-eip-nat-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })
}

resource "aws_nat_gateway" "this" {
  count = length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-nat-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })

  depends_on = [aws_internet_gateway.this]
}
