resource "google_compute_instance" "bastion" {
  name         = "bastion-dev"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"

  # Debian 안정적
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Public Subnet + External IP
  network_interface {
    subnetwork   = var.subnets["subnet-public"].self
    access_config {} # External IP 생성
  }

  tags = ["bastion"]

  metadata = {
     ssh-keys = "debian:${var.bastion_public_key}"
  }

  # 최소한의 로깅/모니터링용 service account (굳이 안 바꿔도 됨)
  service_account {
    email  = var.mgmt_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}