resource "google_project" "project" {
  name       = "A Cloud Guru - GCACE - VPCs"
  project_id = "${var.uid_prefix}-acg-gcace-vpcs"
  billing_account = var.billing_account

  auto_create_network = false
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project  = google_project.project.project_id
  service  = each.value
}
