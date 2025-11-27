###############################################
# Terraform Module: aws/env/modules/eks/
#
# File: outputs.tf 
#
# 설명:
#   - 목적: AWS 환경 EKS 아웃풋
#   - 구성요소: 클러스터명, 엔드포인트, 인증서, 노드 role, 노드 그룹명
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

output "cluster_name"{ 
    description = "EKS 클러스터 이름"
    value = aws_eks_cluster.this.name
}

output "cluster_endpoint"{
    description = "EKS API 서버 엔드포인트 URL"
    value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate"{
    description = "클러스터 CA 인증서 (base64)"
    value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_role_arn"{
    description = "EKS 노드 IAM Role ARN"
    value = aws_iam_role.eks_node.arn
}

output "node_group_name"{
    description = "기본 NodeGroup 이름"
    value = aws_eks_node_group.default.node_group_name
}

output "cluster_sg_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}