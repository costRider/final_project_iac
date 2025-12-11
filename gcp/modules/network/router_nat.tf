
resource "google_compute_router" "this" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.network_name}-router"
  project = var.project_id

  # 첫 번째 subnet의 region 기준으로 생성 (어차피 전부 같은 region 쓸 예정)
  region  = var.subnets[0].region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  count = var.enable_nat ? 1 : 0

  name                               = "${var.network_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.this[0].name
  region                             = google_compute_router.this[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
