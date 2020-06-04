# Example GKE cluster using Terraform

This repository showcases using Terraform to provision a new VPC and a GKE cluster with nodes within.

## Install and configure

Ensure that `kubectl`, `gcloud`, and `terraform` are installed first. This has been tested using Terraform 0.12.

### Initialise Google Cloud CLI

Ensure the [Google Cloud CLI tools](https://cloud.google.com/sdk/docs/quickstarts) are installed and initalised.

  gcloud init

Once initalised, ensure your account is added to the Application Default Credentials (ADC) so Terraform can access them:

  gcloud auth application-default login

### Setup variables

In `terraform.tfvars` set the details according to your Google Cloud account.

`project_id`, `region`, and `gke_location` are required to be set.

`gke_location` is used to specify whether you want a [regional or zone specific cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability).

An example `terraform.tfvars` file of using a single zone cluster with [preemptible GKE nodes](https://cloud.google.com/compute/docs/instances/preemptible):

  project_id      = "my-project-123"
  region          = "australia-southeast1"
  gke_location    = "australia-southeast1-a"
  gke_preemptible = true

There is also a [list of Google Cloud regions](https://cloud.google.com/compute/docs/regions-zones).

## Provisioning

  terraform init
  terraform apply

### Configure kubectl

  gcloud container clusters get-credentials my-cluster-gke --region my-region-123

### Test it works

  kubectl get nodes -o wide
