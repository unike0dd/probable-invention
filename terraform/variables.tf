variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "app_prefix" {
  description = "Resource naming prefix"
  type        = string
  default     = "hc-smb"
}

variable "container_image" {
  description = "Prebuilt container image URI for Cloud Run"
  type        = string
}

variable "owner_email" {
  description = "Operations owner email"
  type        = string
  default     = "[owner]"
}

variable "invoice_email" {
  description = "Default invoice recipient email"
  type        = string
  default     = "[email]"
}
