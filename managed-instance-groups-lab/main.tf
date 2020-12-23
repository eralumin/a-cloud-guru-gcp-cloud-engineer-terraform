resource "google_storage_bucket" "logs" {
  name     = "${var.uid_prefix}-${var.lab_name}-logs"
  location = var.region
}

resource "google_compute_instance_template" "instance_template" {
  name         = "${var.lab_name}-worker-template"
  machine_type = "f1-micro"

  disk {
    source_image = "debian-cloud/debian-9"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  labels = {
    function = "learning"
    madeby   = "template"
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

resource "google_compute_region_instance_group_manager" "region_instance_group_manager" {
  name = "${var.lab_name}-instance-group"

  base_instance_name = "${var.lab_name}-worker-from-igm"
  region               = var.region

  version {
    instance_template  = google_compute_instance_template.instance_template.id
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  name = "${var.lab_name}-autoscaler"
  target = google_compute_region_instance_group_manager.region_instance_group_manager.id

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 5
    cooldown_period = 30

    cpu_utilization {
      target = 0.3
    }
  }
}