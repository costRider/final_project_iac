output "repo_urls" {
  description = "각 repo의 풀 URL (asia-...-docker.pkg.dev/... 형식)"
  value = {
    for k, v in google_artifact_registry_repository.this :
    k => v.repository_url
  }
}