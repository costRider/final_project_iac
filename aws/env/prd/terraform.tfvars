# This file supplies production environment variable values for the ap-northeast-2 deployment.

project_name = "finalproj"
environment  = "prd"
aws_region   = "ap-northeast-2"
region_code  = "apne2"

cluster_name    = "k8s-eks"
cluster_version = "1.33"

vpc_cidr = "10.10.0.0/16"

# CIDR Schema에 맞추어 작성 10.{AWS/prd}.{sub/zone}.0/24
public_subnet_cidrs       = ["10.12.10.0/24", "10.12.12.0/24"]
private_mgmt_subnet_cidrs = ["10.12.20.0/24", "10.12.22.0/24"]
private_app_subnet_cidrs  = ["10.12.30.0/24", "10.12.32.0/24"]
private_db_subnet_cidrs   = ["10.12.40.0/24", "10.12.42.0/24"]

# CIDR 구성에 맞추어 a,c 로 구성(0,2)
azs = ["ap-northeast-2a", "ap-northeast-2c"]

my_ip_cidr = "180.70.43.251/32"
ssh_key_name = "academyKey"

bastion_ami_id        = "ami-0aa02302a11ea5190"
mgmt_ami_id           = "ami-0aa02302a11ea5190"
instance_type_bastion = "t3.micro"
instance_type_mgmt    = "t3.small"

node_instance_types_default = ["t3.small"]
node_instance_types_app     = ["t3.small"]
node_instance_types_obs     = ["t3.medium"]

node_capacity_type = "ON_DEMAND"
node_desired_size  = 2
node_disk_size     = 30
node_min_size      = 1
node_max_size      = 4

owner       = "mklee"
cost_center = "petclinic-prd"
