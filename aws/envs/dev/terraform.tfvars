#####################################
# 2025.11.15 - LMK
# 실제 개인 프로젝트 값
# 실제 사용할 값들을 환경별로 여기에 적어두고 
# main/variables에는 기본 구조만 남기는 패턴
#####################################

################################
# 1. Network Value
################################

aws_region   = "ap-northeast-2"
project_name = "petclinic-eks"

#개인 프로젝트 VPC대역
vpc_cidr = "10.10.0.0/16"

# 2개 AZ에 퍼블릭/프라이빗 서브넷을 각각 구성하는 예
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
mgmt_subnet_cidrs   = ["10.10.11.0/24", "10.10.12.0/24"]
worker_subnet_cidrs = ["10.10.21.0/24", "10.10.22.0/24"]
db_subnet_cidrs     = ["10.10.31.0/24", "10.10.32.0/24"]

azs = ["ap-northeast-2a", "ap-northeast-2c"]

#내 IP
my_ip_cidr = "180.70.43.251/32"

#키페어
ssh_key_name = "academyKey"

#이미지 ID(Amazon Linux 2023 kernel-6.12 AMI 64bit-x86)
bastion_ami_id        = "ami-0aa02302a11ea5190"
mgmt_ami_id           = "ami-0aa02302a11ea5190"
instance_type_bastion = "t3.micro"
instance_type_mgmt    = "t3.small"

################################
# 2. EKS value
################################

cluster_name    = "k8s-eks"
cluster_version = "1.33"

#노드별 인스턴스 타입 지정
node_instance_types_default = ["t3.small"]
node_instance_types_app     = ["t3.small"]
node_instance_types_obs     = ["t3.medium"]

node_capacity_type = "ON_DEMAND"
node_desired_size  = 2
node_disk_siez     = 30
node_min_size      = 1
node_max_size      = 4

####################
#   태그 값
####################

environment = "dev"
owner       = "mklee"
cost_center = "petclinic-lab"