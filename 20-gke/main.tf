provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "ar-ai-dev-krc"
  format        = "DOCKER"
  description   = "Docker repository for GKE lab"
}

resource "google_service_account" "gke_node" {
  account_id   = "sa-gke-node-ai-dev"
  display_name = "GKE node service account"
}

resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  depends_on = [google_project_service.container]
}

resource "google_container_node_pool" "user_pool" {
  name       = "np-ai-user"
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    machine_type    = var.machine_type
    service_account = google_service_account.gke_node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
