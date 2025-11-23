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
#   - 최근 수정일: 2025-11-23
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-22 / 관리용 헤더 템플릿 업데이트 / 작성자: LMK 
#   - 2025-11-23 / DB용 IAM 작성 / 작성자: LMK 
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

# EKS Cluster 컨트롤 IAM 정책 생성 
resource "aws_iam_policy" "mgmt_eks_required_api" {
  name        = "${var.project_name}-mgmt-eks-required-api"
  description = "Required IAM permissions to access EKS clusters as per AWS documentation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EksRequiredAPIActions",
        Effect = "Allow",
        Action = [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeAddonVersions",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListIdentityProviderConfigs",
          "eks:DescribeIdentityProviderConfig"
        ],
        Resource = "*"
      },
      {
        Sid    = "IamAndSts",
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:GetOpenIDConnectProvider",
          "sts:AssumeRole"
        ],
        Resource = "*"
      }
    ]
  })
}

# 생성한 정책 붙이기
resource "aws_iam_role_policy_attachment" "mgmt_eks_required_api_attach" {
  role       = aws_iam_role.mgmt.name
  policy_arn = aws_iam_policy.mgmt_eks_required_api.arn
}

# Role + 정책 매핑한 역할 생성
resource "aws_iam_instance_profile" "mgmt" {
  name = "${var.project_name}-mgmt-profile"
  role = aws_iam_role.mgmt.name
}

#######################################
# Pod Identity 용 IAM Role
#######################################
#RDS에 대한 Describe 권한 + (확장 시) RDS IAM Auth/SecretsManager를 붙일 수 있는 최소 스켈레톤
data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]  # Pod Identity용 Principal :contentReference[oaicite:1]{index=1}
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

## IAM Role 역할 생성

resource "aws_iam_role" "petclinic_pod_role" {
  name               = "petclinic-pod-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = {
    Name = "petclinic-pod-role"
  }
}

# 여기엔 실제로 필요한 권한을 넣으면 됨
# - RDS IAM Auth를 쓸 거면 rds-db:connect, rds:DescribeDBInstances 등
# - Secrets Manager/SSM에서 비밀번호 가져올 거면 secretsmanager:GetSecretValue, ssm:GetParameter 등
data "aws_iam_policy_document" "petclinic_pod_policy" {
  statement {
    effect = "Allow"

    actions = [
      "rds:DescribeDBInstances",
      "rds-db:connect"             # IAM auth 사용할 때
      # "secretsmanager:GetSecretValue" # SecretsManager 이용시
    ]

    resources = ["*"] # 필요하면 나중에 특정 ARN으로 좁히기
  }
}
# IAM 정책생성
resource "aws_iam_policy" "petclinic_pod_policy" {
  name   = "petclinic-pod-policy"
  policy = data.aws_iam_policy_document.petclinic_pod_policy.json
}
# role 정책 매핑
resource "aws_iam_role_policy_attachment" "petclinic_pod_attach" {
  role       = aws_iam_role.petclinic_pod_role.name
  policy_arn = aws_iam_policy.petclinic_pod_policy.arn
}
