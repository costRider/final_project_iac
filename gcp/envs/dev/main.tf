
module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  network_name = "vpc-dr-dev"
  subnets      = var.subnets

  enable_nat = true
}

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id

  enable_mgmt_sa = true
  enable_gke_sa  = true
}

module "security" {
  source     = "../../modules/security"
  project_id = var.project_id

  network_name      = module.network.network_name
  vpc_cidr          = var.vpc_cidr
  ssh_source_ranges = var.ssh_source_ranges
}

module "compute" {
  source     = "../../modules/compute"
  project_id = var.project_id
  region     = var.gcp_region
  zone       = var.gcp_zone[0]

  network_name = module.network.network_name
  subnets      = module.network.subnets

  bastion_public_key = var.bastion_ssh_public_key
  mgmt_sa_email      = module.iam.mgmt_sa_email
}