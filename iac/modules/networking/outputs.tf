output "network_self_link" {
  description = "GKE private main network interface"
  value       = google_compute_network.main.self_link
}

output "private_subnetwork_link" {
  description = "GKE private subnetwork network interface"
  value       = google_compute_subnetwork.private.self_link
}
