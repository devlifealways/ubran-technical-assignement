provider "google" {
  region      = element(var.gcp_node_locations, 0)
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project_id
}

