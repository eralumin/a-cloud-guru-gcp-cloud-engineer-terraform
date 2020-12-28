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

  priority = 500
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

  priority = 800
}

resource "google_compute_firewall" "deny-backend-ingress" {
  project   = google_project.project.project_id
  name      = "deny-backend-ingress"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  target_service_accounts = [google_service_account.backend.email]

  deny {
    protocol = "all"
  }
}

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

resource "google_compute_firewall" "allow-backend-to-backend-egress" {
  project   = google_project.project.project_id
  name      = "allow-backend-to-backend-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  target_service_accounts = [google_service_account.backend.email]
  destination_ranges      = [google_compute_subnetwork.backend.ip_cidr_range]

  allow {
    protocol = "icmp"
  }

  priority = 60000
}

resource "google_compute_firewall" "block-backend-egress" {
  project   = google_project.project.project_id
  name      = "block-backend-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  target_service_accounts = [google_service_account.backend.email]
  destination_ranges      = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  priority = 65000
}

resource "google_compute_firewall" "allow-all-egress" {
  project   = google_project.project.project_id
  name      = "allow-all-egress"
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  priority = 65535
}

resource "google_compute_firewall" "deny-all-ingress" {
  project   = google_project.project.project_id
  name      = "deny-all-ingress"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  priority = 65535
}
