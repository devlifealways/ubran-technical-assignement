# enable compute engines :
# compute.googleapis.com
# cloudresourcemanager.googleapis.com
# container.googleapis.com
# servicenetworking.googleapis.com

locals {
  # here we can enforce our conventions
  network_name        = "${var.gcp_namespace}-main"
  private_subnet_name = "${var.gcp_namespace}-private"
  router_name         = "${var.gcp_namespace}-router"
  nat_name            = "${var.gcp_namespace}-nat"
}

resource "google_project_service" "compute" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.gcp_project_id
  service = "container.googleapis.com"
}

# could use terraform-google-modules/network/google
resource "google_compute_network" "main" {
  name                            = local.network_name
  project                         = var.gcp_project_id
  routing_mode                    = var.gcp_routing_mode
  auto_create_subnetworks         = false
  mtu                             = var.gcp_mtu
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

resource "google_compute_subnetwork" "private" {
  name                     = local.private_subnet_name
  ip_cidr_range            = "10.0.0.0/18"
  region                   = var.gcp_region
  project                  = var.gcp_project_id
  network                  = google_compute_network.main.id
  private_ip_google_access = true # access google APIs and services (db ...etc.)

  log_config {
    aggregation_interval = "INTERVAL_15_MIN"
    flow_sampling        = var.gcp_flow_log_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }

  dynamic "secondary_ip_range" {
    for_each = [for t in var.gcp_vpc_secondary_ip_ranges : t.secondary_range]

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# VMs without public IPs can reach out to IPs and download docker images
# could have used https://github.com/terraform-google-modules/terraform-google-cloud-router
resource "google_compute_router" "router" {
  name    = local.router_name
  project = var.gcp_project_id
  region  = var.gcp_region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  name    = local.nat_name
  project = var.gcp_project_id
  router  = google_compute_router.router.name
  region  = var.gcp_region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  name         = local.nat_name
  project      = var.gcp_project_id
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  region = var.gcp_region

  depends_on = [
    google_project_service.compute
  ]
}
