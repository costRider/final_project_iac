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
#   - 최근 수정일: 2025-11-30
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
#   - 2025-11-30 / Github OIDC Provider, Role 정책 / 작성자: LMK 
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
  description = "Required IAM permissions for mgmt EC2 to access EKS and manage Terraform remote state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      ### -----------------------------
      ### 1) EKS 기본 API 접근 권한
      ### -----------------------------
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

      ### -----------------------------
      ### 2) IAM / STS (EKS Auth 용)
      ### -----------------------------
      {
        Sid    = "IamAndSts",
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:GetOpenIDConnectProvider",
          "sts:AssumeRole"
        ],
        Resource = "*"
      },

      ### -----------------------------
      ### 3) Terraform S3 Backend 접근
      ### -----------------------------
      {
        Sid    = "TerraformStateBucketObjects",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "*"
      },
      {
        Sid    = "TerraformStateBucketMeta",
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ],
        Resource = "*"
      },

    ]
  })
}

# Infra를 관리하는 수준으로 전환하여 Admin 권한부여
resource "aws_iam_role_policy_attachment" "mgmt_admin" {
  role       = aws_iam_role.mgmt.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
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

# 계정당 하나만 있으면 됨 중복생성 안하도록 조심..

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # GitHub OIDC용 공인 thumbprint (변경 거의 없음)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}

# GitHub Actions가 사용할 메인 개체

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      # 특정 repo만 허용
      values = [
        "repo:${var.github_owner}/${var.github_repo}:*"
      ]
    }

    # (옵션) 브랜치/환경까지 제한하고 싶을 때 예시 - 주석으로만 설명
    # condition {
    #   test     = "StringEquals"
    #   variable = "token.actions.githubusercontent.com:ref"
    #   values = [
    #     "refs/heads/main"
    #   ]
    # }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "finalproj-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Project = "petclinic"
    Env     = "dev"
    Owner   = "github-actions"
  }
}

# Role에 ECR Push 권한 부여 

data "aws_iam_policy_document" "github_actions_ecr" {
  statement {
    sid    = "ECRBasicAuth"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    # 특정 리포지토리로 범위 좁히기
    resources = [
      var.petclinic_ecr_arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "github-actions-petclinic-ecr"
  description = "Allow GitHub Actions to push/pull petclinic images to ECR"
  policy      = data.aws_iam_policy_document.github_actions_ecr.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
