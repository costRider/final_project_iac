variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Artifact Registry region (e.g., asia-northeast3)"
}

variable "repos" {
  description = "생성할 Docker 리포 목록 (예: petclinic, obs 등)"
  type = map(object({
    format = string # 보통은 "DOCKER"
  }))
}
