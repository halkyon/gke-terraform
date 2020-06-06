terraform {
  required_version = ">= 0.12"
}

provider "google" {
  version = "~> 3.0"
  project = var.project_id
  region  = local.gcp_region
}

locals {
  gcp_location_parts = split("-", var.gcp_location)
  gcp_region         = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])
}

resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.project_id}-subnet"
  region                   = local.gcp_region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = var.nodes_cidr
  private_ip_google_access = true
}

resource "google_container_cluster" "cluster" {
  name                     = "${var.project_id}-gke"
  location                 = var.gcp_location
  initial_node_count       = 1
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  min_master_version       = "latest"
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.services_cidr
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_cidr
  }
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  }
}

resource "google_container_node_pool" "nodes" {
  name       = "${google_container_cluster.cluster.name}-node-pool"
  cluster    = google_container_cluster.cluster.name
  location   = var.gcp_location
  node_count = var.default_node_count
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = var.node_type
    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type
    preemptible  = var.node_preemptible
    metadata = {
      disable-legacy-endpoints = "true"
    }
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }
}

output "gcp_location" {
  value       = var.gcp_location
  description = "GCP location"
}

output "gke_cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE cluster name"
}
