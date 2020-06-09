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

resource "google_compute_network" "network" {
  name                    = "${var.project_id}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.project_id}-subnet"
  region                   = local.gcp_region
  network                  = google_compute_network.network.name
  ip_cidr_range            = var.nodes_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "${var.project_id}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.network.id
}

resource "google_compute_address" "address" {
  count  = var.nat_ip_count
  name   = "${var.project_id}-nat-ip-${count.index}"
  region = google_compute_subnetwork.subnet.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_id}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.address[*].self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_container_cluster" "cluster" {
  name                     = "${var.project_id}-gke"
  location                 = var.gcp_location
  initial_node_count       = 1
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  min_master_version       = "latest"
  network                  = google_compute_network.network.name
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
  name               = "${google_container_cluster.cluster.name}-node-pool"
  cluster            = google_container_cluster.cluster.name
  location           = var.gcp_location
  initial_node_count = var.initial_node_count
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
    preemptible  = var.node_preemptible
    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type
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
  value = var.gcp_location
}

output "gke_cluster_name" {
  value = google_container_cluster.cluster.name
}
