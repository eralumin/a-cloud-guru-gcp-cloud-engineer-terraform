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
