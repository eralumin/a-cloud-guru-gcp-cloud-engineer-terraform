resource "google_storage_bucket" "logs" {
  name     = "${var.uid_prefix}-${var.lab_name}-logs"
  location = var.region
}

resource "google_compute_instance" "instance" {
  name         = "${var.uid_prefix}-${var.lab_name}-instance"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    lab-logs-bucket = google_storage_bucket.logs.url
  }

  metadata_startup_script = file("${var.lab_name}/worker-startup-script.sh")

  service_account {
    scopes = [
      "logging-write",
      "monitoring-write",
      "service-control",
      "service-management",
      "storage-rw",
      "trace-append",
    ]
  }
}
