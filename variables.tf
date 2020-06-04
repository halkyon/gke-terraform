variable "project_id" {
  description = "GCP project id"
}

variable "gcp_location" {
  description = "GCP region or zone"
}

variable "default_node_count" {
  default = 1
}

variable "min_node_count" {
  default = 1
}

variable "max_node_count" {
  default = 2
}

variable "node_type" {
  default = "n1-standard-1"
}

variable "node_disk_type" {
  default = "pd-ssd"
}

variable "node_disk_size_gb" {
  default = 100
}

variable "node_preemptible" {
  default = false
}

variable "master_cidr" {
  default = "172.16.0.0/28"
}

variable "nodes_cidr" {
  default = "10.1.0.0/20"
}

variable "pods_cidr" {
  default = "10.2.0.0/14"
}

variable "services_cidr" {
  default = "10.3.0.0/20"
}
