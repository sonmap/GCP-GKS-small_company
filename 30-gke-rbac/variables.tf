variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_config_context" {
  type = string
}

variable "developer_group_email" {
  type        = string
  description = "Google Group email used as Kubernetes RBAC subject."
}
