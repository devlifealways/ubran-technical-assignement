# Terraform Kubernetes Engine Module

This atomic module handles opinionated GKE's network creation and configuration, Firewalls and Network Policies

## Compatibility

This module was tested only against Terraform 1.2.3
If you find incompatibilities using other versions, please open an issue.

Otherwise just stick to the same versions using our lock file

## Usage

It's straight forward, you have few madatory inputs

```hcl
module "networking" {
  source              = "./modules/networking" # could be published into terraform's registry
  gcp_project_id      = <PROJECT_ID>
  gcp_region          = <REGION>
  gcp_namespace       = <PREFIX>
  gcp_organization_id = <ORGANIZATION>
}
```

Once done, then perform the following commands on the root folder:

- `terraform fmt` to get the plugins
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform graph > input.dot && dot -Tpng input.dot > output.png && xdg-open ouput.png` to visualize the dependency graph (optional for a better understanding)
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

## Inputs

| Name                    | Description                                                                                                     | Type      | Default    | Required |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- | --------- | ---------- | :------: |
| gcp_routing_mode        | Whether Cloud Routers in a VPC network are regional or global depends on the VPC network's dynamic routing mode | `string`  | `REGIONAL` |    no    |
| gcp_region              | Which region should be it deployed to                                                                           | `string`  |            |   yes    |
| gcp_organization_id     | The hierarchical super node of projects                                                                         | `number`  |            |   yes    |
| gcp_mtu                 | Maximum Transmission Unit in bytes                                                                              | `number`  | 1500       |    no    |
| gcp_private_subnet_name | Private subnetwork name                                                                                         | `string`  | private    |   yes    |
| gcp_project_id          | Google project identifier                                                                                       | `string`  | private    |   yes    |
| gcp_namespace           | Prefix to be appended to all resources                                                                          | `string`  | urban      |    no    |
| gcp_flow_log_sampling   | Records a sample of network flows sent from and received by VM instances                                        | `number`  | 0          |    no    |
| gcp_enable_policies     | Records a sample of network flows sent from and received by VM instances                                        | `boolean` | 0          |    no    |

## Requirements

Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Terraform and kubectl are [installed](#software-dependencies) on the machine where Terraform is executed
2. The Service Account you execute the module with has the right [permissions](#configure-a-service-account) :

   ```shell
   $ gcloud iam service-accounts create <SERVICE_ACCOUNT_NAME>
   # attach needed roles
   $ bash -c 'for gcp_managed_role in roles/compute.admin roles/iam.serviceAccountUser roles/resourcemanager.projectIamAdmin roles/container.admin; do gcloud projects add-iam-policy-binding <PROJECT_NAME> --member serviceAccount:<SERVICE_ACCOUNT_NAME>@<PROJECT_NAME>.iam.gserviceaccount.com --role $gcp_managed_role; done'
   ```

3. The Compute Engine and Kubernetes Engine APIs are [active](#enable-apis) on the project you will launch the cluster in

   ```shell
   $ bash -c 'for gcp_service in compute.googleapis.com cloudresourcemanager.googleapis.com container.googleapis.com servicenetworking.googleapis.com; do gcloud services enable $gcp_service; done'
   ```

### Software Dependencies

#### Kubectl

- [kubectl](https://github.com/kubernetes/kubernetes/releases) 1.22.x

#### Terraform and Plugins

- [Terraform](https://www.terraform.io/downloads.html) 1.2.5
- [Terraform Provider for GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs) 4.29.0

#### gcloud

Some submodules use the [terraform-google-gcloud](https://github.com/terraform-google-modules/terraform-google-gcloud) module. By default, this module assumes you already have gcloud installed in your $PATH.
See the [module](https://github.com/terraform-google-modules/terraform-google-gcloud#downloading) documentation for more information.

### Enable APIs

In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - compute.googleapis.com
- Kubernetes Engine API - container.googleapis.com
- Cloud Resource Manager API - cloudresourcemanager.googleapis.com
- Service Networing API - servicenetworking.googleapis.com

### References

[Google Terraform provider 22.0.0](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/22.0.0)
