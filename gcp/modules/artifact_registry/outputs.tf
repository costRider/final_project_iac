output "repo_urls" {
  description = "Artifact Registry repository URLs"
  value = {
    for k, v in google_artifact_registry_repository.this :
    k => "${v.location}-docker.pkg.dev/${v.project}/${v.repository_id}"
  }
}