
module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  network_name = "vpc-dr-dev"
  subnets      = var.subnets

  enable_nat = true
}

module "security" {
  source     = "../../modules/security"
  project_id = var.project_id

  network_name      = module.network.network_name
  vpc_cidr          = var.vpc_cidr
  ssh_source_ranges = var.ssh_source_ranges
}
