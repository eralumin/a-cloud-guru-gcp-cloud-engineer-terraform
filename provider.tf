provider "google" {
    project = "${var.uid_prefix}-acg-gcace"
    region = var.region
    zone = var.zone
}
