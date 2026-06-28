provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  vpc_name    = coalesce(var.vpc_name, "vpc-${var.name_prefix}")
  subnet_name = coalesce(var.subnet_name, "snet-gke-${var.name_prefix}")

  internal_source_ranges = [
    var.subnet_primary_cidr,
    var.pods_range_cidr,
    var.services_range_cidr,
  ]
}

resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "gke" {
  name          = local.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_primary_cidr

  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_range_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_range_cidr
  }

  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_firewall" "allow_internal" {
  name    = "fw-${local.vpc_name}-allow-internal"
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

  source_ranges = local.internal_source_ranges
}
