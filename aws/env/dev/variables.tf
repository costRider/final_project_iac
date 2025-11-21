# This file lists variable declarations for the dev environment stack.

variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "region_code" { type = string, default = null }
variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_mgmt_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
variable "my_ip_cidr" { type = string }
variable "bastion_ami_id" { type = string }
variable "mgmt_ami_id" { type = string }
variable "ssh_key_name" { type = string }
variable "instance_type_bastion" { type = string }
variable "instance_type_mgmt" { type = string }
variable "node_instance_types_default" { type = list(string) }
variable "node_instance_types_app" { type = list(string) }
variable "node_instance_types_obs" { type = list(string) }
variable "node_capacity_type" { type = string }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "node_disk_size" { type = number }
variable "owner" { type = string }
variable "cost_center" { type = string }
