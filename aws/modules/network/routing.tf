# This file defines routing tables and associations for the shared network module.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: routing.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 라우팅
#   - 구성요소: public, private route
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

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-rtb-pub-01"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-rtb-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })
}

resource "aws_route_table_association" "mgmt" {
  count = length(aws_subnet.mgmt)

  subnet_id      = aws_subnet.mgmt[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "worker" {
  count = length(aws_subnet.worker)

  subnet_id      = aws_subnet.worker[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
