resource "google_compute_subnetwork" "this" {
  for_each = {
    for s in var.subnets : s.name => s
  }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.this.id

  # GKE secondary range 등은 나중에 role=="app"일 때만 추가해도 됨
}
