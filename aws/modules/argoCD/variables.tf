variable "env" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "namespace" {
  description = "Namespace to install Argo CD into"
  type        = string
  default     = "argocd"
}

variable "server_service_type" {
  description = "Service type for Argo CD server (ClusterIP, LoadBalancer, NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "enable_ingress" {
  description = "Whether to enable ingress for Argo CD server"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Hostname for Argo CD ingress"
  type        = string
  default     = ""
}

variable "ingress_annotations" {
  description = "Annotations for Argo CD ingress"
  type        = map(string)
  default     = {}
}

variable "helm_chart_version" {
  description = "Version of argo-cd Helm chart"
  type        = string
  default     = "" # 빈 값이면 latest 사용
}

# (옵션) bcrypt로 해시된 admin password
variable "admin_password_bcrypt" {
  description = "Bcrypt hashed admin password for Argo CD (optional)"
  type        = string
  default     = ""
  sensitive   = true
}
