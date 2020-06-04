terraform {
  required_version = ">= 0.12"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "gke_location" {
  description = "region for gke"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_initial_node_count" {
  default     = 1
  description = "initial count of gke nodes"
}

variable "gke_min_node_count" {
  default     = 1
  description = "min count of gke nodes"
}

variable "gke_max_node_count" {
  default     = 2
  description = "max count of gke nodes"
}

variable "gke_node_type" {
  default     = "n1-standard-1"
  description = "machine type of gke nodes"
}

variable "gke_node_disk_type" {
  default     = "pd-ssd"
  description = "disk type of gke nodes"
}

variable "gke_node_disk_size_gb" {
  default     = 100
  description = "disk size of gke nodes"
}

variable "gke_node_preemptible" {
  default     = false
  description = "gke nodes are preemptible"
}

resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "primary" {
  name                     = "${var.project_id}-gke"
  location                 = var.gke_location
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "latest"
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  master_auth {
    username = var.gke_username
    password = var.gke_password
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name               = "${google_container_cluster.primary.name}-node-pool"
  cluster            = google_container_cluster.primary.name
  location           = var.gke_location
  initial_node_count = var.gke_initial_node_count
  autoscaling {
    min_node_count = var.gke_min_node_count
    max_node_count = var.gke_max_node_count
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
    machine_type = var.gke_node_type
    disk_size_gb = var.gke_node_disk_size_gb
    disk_type    = var.gke_node_disk_type
    preemptible  = var.gke_node_preemptible
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "region" {
  value       = var.region
  description = "region"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
