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
