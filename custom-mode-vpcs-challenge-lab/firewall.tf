resource "google_compute_firewall" "allow-frontend-ping-ingress" {
  project   = google_project.project.project_id
  name      = "allow-frontend-ping-ingress"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  target_service_accounts = [google_service_account.frontend.email]
  source_ranges           = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}
resource "google_compute_firewall" "allow-backend-ping-ingress" {
  project   = google_project.project.project_id
  name      = "allow-backend-ping-ingress"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  target_service_accounts = [google_service_account.backend.email]
  source_service_accounts = [
    google_service_account.backend.email,
    google_service_account.frontend.email
  ]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "deny-all-backend-egress" {
  project   = google_project.project.project_id
  name      = "deny-all-backend-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  target_service_accounts = [google_service_account.backend.email]

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow-backend-ping-backend-egress" {
  project   = google_project.project.project_id
  name      = "allow-backend-ping-backend-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  target_service_accounts = [google_service_account.backend.email]
  destination_ranges      = [google_compute_subnetwork.backend.ip_cidr_range]

  allow {
    protocol = "icmp"
  }

  priority = 1
}

resource "google_compute_firewall" "allow-ssh" {
  project   = google_project.project.project_id
  name      = "allow-ssh"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  target_tags   = ["open-ssh"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
