variable "project_id" {
  description = "GCP project the cluster should reside in."
}

variable "location" {
  description = <<EOF
Location in GCP the cluster should reside in.
This can be either a region, or a zone (for single-zone clusters.)
See https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability
EOF
}

variable "name" {
  description = "Name of the cluster."
}

variable "nat_ip_count" {
  default     = 1
  description = <<EOF
Number of NAT IPs to provision. More IP addresses means more source ports can be used.
See https://cloud.google.com/nat/docs/overview and
https://cloud.google.com/nat/docs/ports-and-addresses#ports
EOF
}

variable "initial_node_count" {
  default     = 1
  description = <<EOF
Initial node count. This is only used when first provisioning the cluster.
Any external changes made (i.e. autoscaling) will not be overwritten.
EOF
}

variable "min_node_count" {
  default     = 1
  description = "Minimum node count for autoscaling"
}

variable "max_node_count" {
  default     = 2
  description = "Maximum node count for autoscaling"
}

variable "node_type" {
  default     = "n1-standard-1"
  description = <<EOF
Machine type for nodes.
See https://cloud.google.com/compute/docs/machine-types and
https://cloud.google.com/compute/vm-instance-pricing
EOF
}

variable "node_preemptible" {
  default     = false
  description = <<EOF
Whether or not nodes are preemptible.
See https://cloud.google.com/compute/docs/instances/preemptible
EOF
}

variable "node_disk_type" {
  default     = "pd-ssd"
  description = <<EOF
Node disk type. Can be either "pd-standard" or "pd-ssd".
See https://cloud.google.com/compute/docs/disks/
EOF
}

variable "node_disk_size_gb" {
  default     = 100
  description = "Node disk size, in GB."
}

variable "master_cidr" {
  default     = "172.16.0.0/28"
  description = "Kubernetes control plane CIDR."
}

variable "nodes_cidr" {
  default     = "10.1.0.0/20"
  description = <<EOF
Nodes CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "pods_cidr" {
  default     = "/14"
  description = <<EOF
Pods CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "services_cidr" {
  default     = "/20"
  description = <<EOF
Services CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}
