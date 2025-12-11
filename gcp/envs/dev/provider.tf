terraform {
  required_version = "= 1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.13.0"
    }
  }

  backend "gcs" {
    bucket = "final-terraform-gcs"
    prefix = "gcp/env/dev"
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.gcp_region
  zone    = var.gcp_zone[0] # 기본 zone 설정이 없으면 provider zone을 default로 사용
}
