# This module creates IAM roles and policies required by other AWS resources.

###############################################
# Terraform Module: aws/env/modules/iam
#
# File: main.tf 
#
# 설명:
#   - 목적: 개발환경 IAM 모듈
#   - 구성요소: IAM 설정
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

# MGMT에 붙일 Role 생성 - EKS 관리용
resource "aws_iam_role" "mgmt" {
  name = "${var.project_name}-mgmt-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Role에 적용할 정책 생성
resource "aws_iam_role_policy_attachment" "mgmt_ssm" {
  role       = aws_iam_role.mgmt.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "mgmt_eks" {
  role       = aws_iam_role.mgmt.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# Role + 정책 매핑한 역할 생성
resource "aws_iam_instance_profile" "mgmt" {
  name = "${var.project_name}-mgmt-profile"
  role = aws_iam_role.mgmt.name
}


