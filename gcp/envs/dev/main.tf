resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com", # ← GKE
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}



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

  gke_cluster_name = module.gke.cluster_name
}

module "gke" {
  depends_on   = [google_project_service.required_apis]
  source       = "../../modules/gke"
  project_id   = var.project_id
  region       = var.gcp_region
  cluster_name = var.cluster_name

  network_name    = module.network.network_name
  subnet_app_name = module.network.subnets["subnet-app"].name

  gke_node_sa_email = module.iam.gke_node_sa_email

  gke_zones = var.gcp_zone

  min_node_count    = 1
  max_node_count    = 3
  node_machine_type = "e2-standard-2"
}