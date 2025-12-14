# subnet 생성하는 갯수만큼 작성
resource "google_compute_subnetwork" "this" {
  for_each = {
    for s in var.subnets : s.name => s
  }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.this.id
	
  private_ip_google_access = true
# Private GKE secondary range 구성
  dynamic "secondary_ip_range" {
    for_each = coalesce(each.value.secondary_ranges, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}