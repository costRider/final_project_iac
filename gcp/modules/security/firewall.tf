##################################
# resource가 필요로 하는 firewall rule을 생성
##################################
/*
# 내부 전체 트래픽 허용 (VPC 내부 통신)
resource "google_compute_firewall" "internal_all" {
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = var.network_name

  direction     = "INGRESS"
  priority      = 65534
  source_ranges = [var.vpc_cidr]

  allow {
    protocol = "all"
  }
}*/



# Bastion SSH (tags=["bastion"] 달린 인스턴스만 대상)
resource "google_compute_firewall" "ssh_bastion" {
  count = length(var.ssh_source_ranges) > 0 ? 1 : 0

  name    = "${var.network_name}-allow-ssh-bastion"
  project = var.project_id
  network = var.network_name

  direction    = "INGRESS"
  priority     = 1000
  target_tags  = ["bastion"]
  source_ranges = var.ssh_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


resource "google_compute_firewall" "ssh_bastion_to_mgmt" {
  name    = "${var.network_name}-ssh-bastion-to-mgmt"
  project = var.project_id
  network = var.network_name

  direction = "INGRESS"
  priority  = 1000

  target_tags = ["mgmt"]
  source_tags = ["bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# GKE NodePort / 헬스체크, 나중에 필요하면 여기에 추가
# 예: HTTP/HTTPS from Google health check ranges, etc.
