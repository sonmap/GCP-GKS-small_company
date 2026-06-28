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
  description = "Resource name prefix."
  type        = string
  default     = "ai-dev-krc"
}
