###############################################
# GKE Regional Cluster (표준, 라우트 기반)
###############################################

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region          # regional cluster

  network    = var.network_name
  subnetwork = var.subnet_app_name

  # 기본 node pool 끄고 아래에서 별도 node_pool 리소스 사용
  remove_default_node_pool = true
  initial_node_count       = 1

  # VPC-native (Alias) 는 나중에 secondary range 구성 후 붙여도 됨
  # 지금은 단순히 생략해서 route 기반으로 사용
  # ip_allocation_policy {
  #   use_ip_aliases = true
  # }

  # master API endpoint에 대한 접근 제어 (지금은 전체 허용, 나중에 mgmt CIDR로 좁히자)
 master_authorized_networks_config {
  cidr_blocks {
    cidr_block   = "10.20.20.0/24"
    display_name = "mgmt-subnet"
  }
}

  # logging / monitoring 기본값 사용
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # 릴리즈 채널 안정 버전
  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  deletion_protection = false
}

###############################################
# GKE Node Pool (앱/기본 용도 한 개)
###############################################

resource "google_container_node_pool" "default" {
  name       = "${var.cluster_name}-np-default"
  project    = var.project_id
  location   = google_container_cluster.this.location
  cluster    = google_container_cluster.this.name

  node_locations = var.gke_zones

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    service_account = var.gke_node_sa_email

    labels = {
      role      = "default"
      nodegroup = "default"
    }

    tags = ["gke-node-default"]
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}