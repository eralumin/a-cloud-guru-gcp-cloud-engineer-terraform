resource "google_project" "project" {
  name            = "A Cloud Guru - GCACE - VPCs"
  project_id      = "${var.uid_prefix}-acg-gcace-vpcs"
  billing_account = var.billing_account

  auto_create_network = false
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project  = google_project.project.project_id
  service  = each.value
}

resource "google_compute_network" "vpc_network" {
  name    = "app-vpc"
  project = google_project.project.project_id

  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name    = "oregon-subnet"
  project = google_project.project.project_id

  ip_cidr_range = "192.168.0.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

data "google_iam_role" "log_writer" {
  name = "roles/logging.logWriter"
}

data "google_iam_role" "metric_writer" {
  name = "roles/monitoring.metricWriter"
}

resource "google_project_iam_custom_role" "base_gce" {
  role_id = "baseGCE"
  title   = "Base GCE"
  project = google_project.project.project_id

  permissions = concat(
    data.google_iam_role.log_writer.included_permissions,
    data.google_iam_role.metric_writer.included_permissions
  )
}

resource "google_service_account" "frontend" {
  account_id   = "frontend"
  display_name = "Service Account for Frontend Servers"

  project = google_project.project.project_id
}

resource "google_project_iam_binding" "base_gce_role_binding" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.base_gce.name

  members = [
    "serviceAccount:${google_service_account.frontend.email}",
  ]
}

resource "google_compute_instance_template" "instance_template" {
  project = google_project.project.project_id
  name         = "${var.lab_name}-frontend-it"
  machine_type = "f1-micro"
  region = google_compute_subnetwork.subnet.region

  disk {
    source_image = "debian-cloud/debian-9"
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.name
    subnetwork_project = google_project.project.project_id

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email = google_service_account.frontend.email
    scopes = []
  }
}

resource "google_compute_region_instance_group_manager" "region_instance_group_manager" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-frontend-it-group"

  base_instance_name = "${var.lab_name}-frontend-instance"
  region             = google_compute_subnetwork.subnet.region

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-frontend-autoscaler"
  region  = google_compute_subnetwork.subnet.region
  target  = google_compute_region_instance_group_manager.region_instance_group_manager.id

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 3
  }
}

resource "google_compute_firewall" "allow-incoming-to-frontend" {
  project   = google_project.project.project_id
  name      = "allow-incoming-to-frontend"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  target_service_accounts = [google_service_account.frontend.email]
  source_ranges           = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

