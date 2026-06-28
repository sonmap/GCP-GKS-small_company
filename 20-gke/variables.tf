variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-northeast3"
}

variable "cluster_name" {
  type    = string
  default = "gke-ai-dev-krc"
}

variable "network" {
  type    = string
  default = "vpc-ai-dev-krc"
}

variable "subnetwork" {
  type    = string
  default = "snet-gke-ai-dev-krc"
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}
