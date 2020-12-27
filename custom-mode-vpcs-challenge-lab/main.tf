resource "google_project" "project" {
  name            = "A Cloud Guru - GCACE - VPCs C"
  project_id      = "${var.uid_prefix}-acg-gcace-vpcs-c"
  billing_account = var.billing_account

  auto_create_network = false
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project  = google_project.project.project_id
  service  = each.value
}

resource "google_compute_network" "vpc_network" {
  name    = "vpc-challenge-lab"
  project = google_project.project.project_id

  routing_mode = "GLOBAL"
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

resource "google_service_account" "backend" {
  account_id   = "backend"
  display_name = "Service Account for Backend Servers"

  project = google_project.project.project_id
}

resource "google_project_iam_binding" "base_gce_role_binding" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.base_gce.name

  members = [
    "serviceAccount:${google_service_account.backend.email}",
    "serviceAccount:${google_service_account.frontend.email}",
  ]
}
