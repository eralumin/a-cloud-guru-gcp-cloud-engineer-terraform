
resource "google_project" "project" {
  name       = "A Cloud Guru - GCACE"
  project_id = "${var.uid_prefix}-acg-gcace"
  billing_account = var.billing_account
}
