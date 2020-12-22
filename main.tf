
resource "google_project" "project" {
  name       = "A Cloud Guru - GCACE"
  project_id = "${var.uid_prefix}-acg-gcace"
  billing_account = var.billing_account
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project  = google_project.project.project_id
  service  = each.value
}

module "gcs_and_gce_challenge_lab" {
  source = "./gcs-and-gce-challenge-lab"
  uid_prefix = var.uid_prefix
  region = var.region
}