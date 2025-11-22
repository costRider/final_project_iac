# This file exports network attributes such as VPC, subnet, and security group IDs.

###############################################
# Terraform Module: aws/env/dev/network
#
# File: outputs.tf 
#
# 설명:
#   - 목적: 개발환경 네트워크 아웃풋
#   - 구성요소: VPC, 서브넷, 보안그룹, 라우팅 테이블, bastion(public)IP, mgmt(private)IP
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

output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 리스트"
  value       = [for s in aws_subnet.public : s.id]
}

output "mgmt_subnet_ids" {
  description = "관리 프라이빗 서브넷 ID 리스트"
  value       = [for s in aws_subnet.mgmt : s.id]
}

output "worker_subnet_ids" {
  description = "애플리케이션 프라이빗 서브넷 ID 리스트"
  value       = [for s in aws_subnet.worker : s.id]
}

output "db_subnet_ids" {
  description = "DB 프라이빗 서브넷 ID 리스트"
  value       = [for s in aws_subnet.db : s.id]
}

output "bastion_sg_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}

output "mgmt_sg_id" {
  description = "MGMT Security Group ID"
  value       = aws_security_group.mgmt.id
}

output "node_sg_id" {
  description = "Node Security Group ID"
  value       = aws_security_group.node.id
}

output "db_sg_id"{
  description = "DB Security Group ID"
  value = aws_security_group.db.id
}

output "public_route_table_id" {
  description = "퍼블릭 라우트 테이블 ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "프라이빗 라우트 테이블 ID"
  value       = [for s in aws_route_table.private : s.id]
}