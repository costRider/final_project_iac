###############################################
# Terraform Module: aws/env/modules/eks/
#
# File: main.tf 
#
# 설명:
#   - 목적: AWS 환경 EKS 모듈
#   - 구성요소: EKS iam role + 정책, cluster, node, cluster security group, 접근 권한 설정
#
# 관리 정보:
#   - 최초 작성일: 2025-11-22
#   - 최근 수정일: 2025-11-27
#   - 작성자: LMK
#   - 마지막 수정자: LMK
#
# 버전 정보:
#   - Terraform: >= 1.5.0
#   - Provider: AWS ~> 6.0
#
# 변경 이력:
#   - 2025-11-22 / 관리용 헤더 템플릿 업데이트 / 작성자: LMK 
#   - 2025-11-27 / EC2 MGMT 접근 권한 업데이트 / 작성자: LMK
#
# 주의 사항:
#   - 이 모듈은 <AWS> 전용입니다.
#   - 변수 값은 env 디렉토리 내 tfvars에서 관리합니다.
#   - providers/backend는 env(dev,stg,prd) 단위에서 적용됩니다.
###############################################

####################################
#   1. EKS Cluster IAM Role
####################################

# 역할 생성
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"
  assume_role_policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    }
  )
}

# 역할에 정책 Mapping 
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  role = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

####################################
#   2. EKS NodeGroup IAM Role
####################################

resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

####################################
#   3. EKS Cluster Security Group
####################################

resource "aws_security_group" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS control plane endpoint"
  vpc_id = var.vpc_id

  #기본 VPC 전체에서 443으로 접근 허용
  ingress {
    description = "Allow HTTPS from worker nodes SG"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = compact([
        var.mgmt_sg_id
      ])
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags,{
    Name = "${var.project_name}-eks-cluster-sg"
  })

}


####################################
#   4. EKS Cluster (Control Plane)
####################################
resource "aws_eks_cluster" "this" {
  name = var.cluster_name
  version = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    #EKS ENI가 생성될 서브넷들(worker 서브넷 재사용)
    subnet_ids = var.worker_subnet_ids

    #control plane sg + 필요시 추가 SG
    security_group_ids = concat([aws_security_group.eks_cluster.id],var.cluster_additional_sg_ids)
  
    endpoint_public_access = false # 퍼블릭 차단
    endpoint_private_access = true # 내부 접근용으로 활성화
  }

  kubernetes_network_config {
    #cluster_ip CIDR - 기본 값 쓰려면 생략 가능, 명시하고 싶으면 설정
    #service_ipv4_cidr = "192.10.0.0/16"
    service_ipv4_cidr = "192.168.0.0/16"
  }
  # API 기반으로도 접근하고 Config 기반으로도 접근하기 위함
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = var.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

########################################
# 5. EKS Managed Node Group(app)
########################################

resource "aws_eks_node_group" "app" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-app"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = var.worker_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size = var.node_min_size
    max_size = var.node_max_size
  }

  capacity_type = var.node_capacity_type # ON_DEMAND or Spot

  instance_types = var.node_instance_types_app

  disk_size = var.node_disk_size

  //labels = var.node_lables3

  labels = {
    role = "app"
    nodegroup = "app"
  }

  taint {
    key = "role"
    value = "app"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.common_tags,{
    Name = "${var.cluster_name}-ng-app"
  })

  depends_on = [ aws_eks_cluster.this,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy 
  ]
}

########################################
# 5. EKS Managed Node Group(obs)
########################################

resource "aws_eks_node_group" "obs" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-obs"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = var.worker_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size = var.node_min_size
    max_size = var.node_max_size
  }

  capacity_type = var.node_capacity_type # ON_DEMAND or Spot

  instance_types = var.node_instance_types_obs

  disk_size = var.node_disk_size

  //labels = var.node_lables

  labels = {
    role = "obs"
    nodegroup = "obs"
  }

  taint {
    key = "role"
    value = "obs"
    effect = "NO_SCHEDULE"
  }

  tags = merge(var.common_tags,{
    Name = "${var.cluster_name}-ng-obs"
  })

  depends_on = [ aws_eks_cluster.this,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy 
  ]
}

########################################
# 5. EKS Managed Node Group(default)
########################################

resource "aws_eks_node_group" "default" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-default"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = var.worker_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size = var.node_min_size
    max_size = var.node_max_size
  }

  capacity_type = var.node_capacity_type # ON_DEMAND or Spot

  instance_types = var.node_instance_types_default

  disk_size = var.node_disk_size

  //labels = var.node_lables

  tags = merge(var.common_tags,{
    Name = "${var.cluster_name}-ng-default"
  })

  depends_on = [ aws_eks_cluster.this,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy 
  ]
}

##########################################
# AccessEntry로 MGMT EC2 IAM을 EKS admin으로 등록 / API기반 접근
##########################################
resource "aws_eks_access_entry" "mgmt" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.mgmt_role_arn
  type = "STANDARD"   # EC2 또는 STANDARD 사용

  depends_on    = [aws_eks_cluster.this]
}

# 등록한 내용에 대해 어떤 역할을 부여할 것인지 연결
resource "aws_eks_access_policy_association" "mgmt_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.mgmt.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"   # 전체 클러스터 범위
  }

  depends_on    = [aws_eks_access_entry.mgmt]
}


# pod identity에 정책 매핑한 role 연결(Role과 ServiceAccount 연결)
resource "aws_eks_pod_identity_association" "petclinic_pod_identity" {
  cluster_name    = var.cluster_name
  namespace       = var.petclinic_ns
  service_account = var.petclinic_sa
  role_arn        = var.petclinic_pod_role_arn

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_addon.pod_identity_agent,
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  # 버전은 생략하면 자동 최신, 아니면 명시
  # addon_version    = "v1.0.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on    = [aws_eks_cluster.this]

  tags = merge(var.common_tags,{
    Name = "${var.cluster_name}-addon-pod_identity"
  })
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = var.lbc_role_arn

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_cluster.this
  ]
}

