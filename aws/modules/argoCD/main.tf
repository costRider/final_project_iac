resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true

  # chart 버전은 옵션
  version = var.helm_chart_version != "" ? var.helm_chart_version : null

  # 기본 values.yaml (공통 설정들 넣어도 됨)
  values = [
    file("${path.module}/values-argocd.yaml"),
  ]

  # Service 타입
  set {
    name  = "server.service.type"
    value = var.server_service_type
  }

  # Ingress on/off
  set {
    name  = "server.ingress.enabled"
    value = var.enable_ingress
  }

  # Ingress host
  dynamic "set" {
    for_each = var.enable_ingress && var.ingress_host != "" ? [1] : []
    content {
      name  = "server.ingress.hosts[0]"
      value = var.ingress_host
    }
  }

  # Ingress annotations (map → Helm values)
  dynamic "set" {
    for_each = var.enable_ingress ? var.ingress_annotations : {}
    content {
      name  = "server.ingress.annotations.${set.key}"
      value = set.value
    }
  }

  # (옵션) admin 패스워드 해시 주입
  set_sensitive = var.admin_password_bcrypt != "" ? [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = var.admin_password_bcrypt
    }
  ] : []
}
