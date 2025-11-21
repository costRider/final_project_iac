# This file supplies production environment variable values for the ap-northeast-2 deployment.

project_name = "finalproj"
environment  = "prd"
aws_region   = "ap-northeast-2"
region_code  = "apne2"

cluster_name    = "k8s-eks"
cluster_version = "1.30"

vpc_cidr = "10.30.10.0/20"

public_subnet_cidrs       = ["10.30.10.0/24", "10.30.11.0/24"]
private_mgmt_subnet_cidrs = ["10.30.12.0/24", "10.30.13.0/24"]
private_app_subnet_cidrs  = ["10.30.14.0/24", "10.30.15.0/24"]
private_db_subnet_cidrs   = ["10.30.16.0/24", "10.30.17.0/24"]

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
