resource "google_compute_instance" "mgmt" {
  name         = "mgmt-dev"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # mgmt subnet → internal-only
  network_interface {
    subnetwork = var.subnets["subnet-mgmt"].self
    # NOTE: access_config 없음 → internal-only → external SSH 불가
  }

  tags = ["mgmt"]

  metadata = {
      ssh-keys = "debian:${var.bastion_public_key}"
  }

    # 부트스트랩 스크립트
  metadata_startup_script = templatefile("${path.module}/templates/mgmt_startup.sh", {
    terraform_version = var.terraform_version
    cluster_name      = var.gke_cluster_name
    region            = var.region
    project_id        = var.project_id
  })

  # mgmt SA = GCP 인프라 컨트롤러
  service_account {
    email  = var.mgmt_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # 여기에 나중에 startup-script로 code-server / terraform 설치도 가능
}