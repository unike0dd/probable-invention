terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name_prefix = "${var.app_prefix}-${var.environment}"
  labels = {
    app         = var.app_prefix
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_project_service" "services" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "web" {
  location      = var.region
  repository_id = "${local.name_prefix}-web"
  description   = "Docker images for the HarborCart SMB app"
  format        = "DOCKER"
  depends_on    = [google_project_service.services]
}

resource "google_service_account" "cloud_run" {
  account_id   = substr(replace("${local.name_prefix}-run", "_", "-"), 0, 30)
  display_name = "${local.name_prefix} Cloud Run runtime"
}

resource "google_secret_manager_secret" "stripe_publishable_key" {
  secret_id = "${local.name_prefix}-stripe-publishable-key"
  replication { auto {} }
  depends_on = [google_project_service.services]
}

resource "google_cloud_run_v2_service" "web" {
  name     = "${local.name_prefix}-web"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.cloud_run.email
    max_instance_request_concurrency = 80
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
    containers {
      image = var.container_image
      ports { container_port = 8080 }
      env {
        name  = "APP_OWNER_EMAIL"
        value = var.owner_email
      }
      env {
        name  = "APP_INVOICE_EMAIL"
        value = var.invoice_email
      }
      env {
        name = "STRIPE_PUBLISHABLE_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.stripe_publishable_key.secret_id
            version = "latest"
          }
        }
      }
    }
  }
  depends_on = [google_project_service.services]
}

resource "google_cloud_run_service_iam_member" "public" {
  location = google_cloud_run_v2_service.web.location
  service  = google_cloud_run_v2_service.web.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_v2_service.web.uri
}

output "artifact_registry_repo" {
  value = google_artifact_registry_repository.web.id
}
