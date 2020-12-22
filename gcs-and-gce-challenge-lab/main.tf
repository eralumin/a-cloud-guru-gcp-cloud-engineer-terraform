resource "google_storage_bucket" "logs" {
  name          = "${var.uid_prefix}-gcs-and-gce-challenge-lab"
  location      = var.region
}
