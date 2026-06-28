variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "asia-northeast3"
}

variable "name_prefix" {
  description = "Resource name prefix used when explicit names are not provided."
  type        = string
  default     = "ai-dev-krc"
}

variable "vpc_name" {
  description = "Explicit VPC name from Excel design."
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "Explicit GKE subnet name from Excel design."
  type        = string
  default     = null
}

variable "subnet_primary_cidr" {
  description = "Primary CIDR for GKE nodes."
  type        = string
  default     = "10.40.0.0/20"
}

variable "pods_range_name" {
  description = "Secondary range name for GKE Pods."
  type        = string
  default     = "pods"
}

variable "pods_range_cidr" {
  description = "Secondary CIDR range for GKE Pods."
  type        = string
  default     = "10.41.0.0/16"
}

variable "services_range_name" {
  description = "Secondary range name for Kubernetes Services."
  type        = string
  default     = "services"
}

variable "services_range_cidr" {
  description = "Secondary CIDR range for Kubernetes Services."
  type        = string
  default     = "10.42.0.0/20"
}

variable "private_ip_google_access" {
  description = "Enable Private Google Access on the subnet."
  type        = bool
  default     = true
}
