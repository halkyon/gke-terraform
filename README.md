# Example GKE cluster using Terraform

This repository showcases using Terraform to provision a new VPC and a GKE cluster with nodes within.

See a [high level overview of the architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture).

## Install and configure

Ensure that `kubectl`, `gcloud`, and `terraform` are installed first. This has been tested using Terraform 0.12.

### Initialise Google Cloud CLI

Ensure the [Google Cloud CLI tools](https://cloud.google.com/sdk/docs/quickstarts) are installed and initalised.

```shell
gcloud init
```

Once initalised, ensure your account is added to the Application Default Credentials (ADC) so Terraform can access them:

```shell
gcloud auth application-default login
```

### Setup variables

In `terraform.tfvars` set the details according to your Google Cloud account.

`project_id`, and `gcp_location` are required to be set.

`gcp_location` can be set to a region or zone. See [regional or zone specific cluster docs for more information](https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability).

An example `terraform.tfvars` file of using a single zone cluster with [preemptible GKE nodes](https://cloud.google.com/compute/docs/instances/preemptible):

```
project_id      = "my-project-123"
gcp_location    = "australia-southeast1-a"
node_preemptible = true
```

There is also a [list of Google Cloud regions](https://cloud.google.com/compute/docs/regions-zones).

## Provisioning

Initialise Terraform:

```shell
terraform init
```

Optional: you can see what's going to be done before anything is actually created:

```shell
terraform plan
```

Create the resources:

```shell
terraform apply
```

### Configure kubectl

Retrieve the cluster name and location using `terraform show`, then initialise `kubectl` configuration.

```shell
gcloud container clusters get-credentials my-cluster --region my-location
```

### Test it works

```shell
kubectl get nodes -o wide
```

## Tearing down

```shell
terraform destroy
```

## What now?

Check out [`google_container_cluster` Terraform docs](https://www.terraform.io/docs/providers/google/r/container_cluster.html) 
for more details on what GKE parameters can be changed using Terraform.

Another thing to do is to create a NAT gateway for outgoing traffic from private nodes, and configuring firewall rules for node traffic.