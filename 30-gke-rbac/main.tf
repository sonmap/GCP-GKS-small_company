provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}

resource "kubernetes_namespace" "ai_dev" {
  metadata {
    name = "ai-dev"
    labels = {
      env   = "dev"
      owner = "ai"
    }
  }
}

resource "kubernetes_role" "developer" {
  metadata {
    name      = "ai-developer"
    namespace = kubernetes_namespace.ai_dev.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "developer" {
  metadata {
    name      = "rb-ai-dev-developers"
    namespace = kubernetes_namespace.ai_dev.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.developer.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = var.developer_group_email
    api_group = "rbac.authorization.k8s.io"
  }
}
