
# only if you wish to retrieve latest version of kubernetes
# data "google_container_engine_versions" "gke_europe_versions" {
#   provider       = google
#   location       = element(var.gcp_node_locations, 0)
#   version_prefix = "1.21."
# }

# doesn't have any organization
# resource "google_organization_policy" "skip_default_policy" {
#   org_id     = var.gcp_organization_id
#   constraint = "compute.skipDefaultNetworkCreation"
#   boolean_policy {
#     enforced = true
#   }
# }

module "networking" {
  source                      = "./modules/networking"
  gcp_project_id              = var.gcp_project_id
  gcp_region                  = var.gcp_region
  gcp_namespace               = var.gcp_namespace
  gcp_organization_id         = var.gcp_organization_id
  gcp_vpc_secondary_ip_ranges = var.gcp_vpc_secondary_ip_ranges
}

locals {
  cluster_name        = "${var.gcp_namespace}-primary"
  sa_name             = "${var.gcp_namespace}-kubernetes"
  node_pool_name      = "${var.gcp_namespace}-general"
  node_pool_spot_name = "${var.gcp_namespace}-spot"

  # BETA features
  # cluster_istio_enabled                    = !local.cluster_output_istio_disabled
  # cluster_dns_cache_enabled                = var.dns_cache
  # cluster_telemetry_type_is_set            = var.cluster_telemetry_type != null
  # cluster_pod_security_policy_enabled      = local.cluster_output_pod_security_policy_enabled
  # cluster_intranode_visibility_enabled     = local.cluster_output_intranode_visbility_enabled
  # cluster_vertical_pod_autoscaling_enabled = local.cluster_output_vertical_pod_autoscaling_enabled
  # confidential_node_config                 = var.enable_confidential_nodes == true ? [{ enabled = true }] : []
}

# kubernetes cluster
resource "google_container_cluster" "primary" {
  name                     = local.cluster_name
  project                  = var.gcp_project_id
  location                 = var.gcp_region
  remove_default_node_pool = true
  initial_node_count       = 1 # doesn't matter it will be destroyed anyway
  network                  = module.networking.network_self_link
  subnetwork               = module.networking.private_subnetwork_link
  logging_service          = var.gcp_enable_logging ? "logging.googleapis.com/kubernetes" : null       # fleuntbit agent on each node and scrap all logs of your applications
  monitoring_service       = var.gcp_enable_monitoring ? "monitoring.googleapis.com/kubernetes" : null # if you wish to use prometheus, then disable this
  networking_mode          = "VPC_NATIVE"
  node_locations           = var.gcp_node_locations

  addons_config {
    http_load_balancing {
      disabled = true # will use traefik ingress controller
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-ips"
    services_secondary_range_name = "k8s-svc-ips"
  }

  private_cluster_config {
    enable_private_nodes    = true  # enable private NAT : private IP addresses
    enable_private_endpoint = false # bastion host or VPN
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

# service account for GKE cluster and node pools
resource "google_service_account" "kubernetes" {
  project      = var.gcp_project_id
  account_id   = local.sa_name
  display_name = local.sa_name
}

resource "google_container_node_pool" "general" {
  name       = local.node_pool_name
  cluster    = google_container_cluster.primary.id
  node_count = var.gcp_node_pool_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.gcp_primary_pool_autoscaling_min_count
    max_node_count = var.gcp_primary_pool_autoscaling_max_count
  }

  node_config {
    disk_size_gb = var.gcp_node_pool_disk_size # free-tier
    preemptible  = false
    machine_type = var.gcp_machine_flavor

    labels = {
      role = terraform.workspace
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}


# handy for stateless, batch, or fault-tolerant workloads
# than can tolerate disruptions caused by the ephemeral nature of Spot VMs
# and you'll need to explicitly set your deployments to tolerates the taints
resource "google_container_node_pool" "spot" {
  name    = local.node_pool_spot_name
  cluster = google_container_cluster.primary.id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.gcp_spot_pool_autoscaling_min_count
    max_node_count = var.gcp_spot_pool_autoscaling_max_count
  }

  node_config {
    preemptible  = true
    machine_type = var.gcp_machine_flavor

    labels = {
      team       = "devops"
      enviroment = terraform.workspace
    }

    taint {
      key    = "instance_type"
      value  = local.node_pool_spot_name
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
