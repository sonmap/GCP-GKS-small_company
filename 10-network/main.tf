provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.name_prefix}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name          = "snet-gke-${var.name_prefix}"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.40.0.0/20"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.41.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.42.0.0/20"
  }

  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_internal" {
  name    = "fw-${var.name_prefix}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.40.0.0/20", "10.41.0.0/16", "10.42.0.0/20"]
}
