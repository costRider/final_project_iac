resource "google_artifact_registry_repository" "this" {
  for_each = var.repos

  project       = var.project_id
  location      = var.region
  repository_id = each.key            # 예: petclinic
  format        = each.value.format   # 보통 DOCKER

  description   = "Artifact Registry repo for ${each.key}"
}