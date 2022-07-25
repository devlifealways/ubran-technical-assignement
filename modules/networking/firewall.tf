# could do the same thing as here :
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/modules/beta-public-cluster/firewall.tf

# allow ssh into kubernetes nodes : optional (check enabled kernel options)
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  project = var.gcp_project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
