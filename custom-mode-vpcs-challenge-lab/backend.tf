resource "google_compute_subnetwork" "backend" {
  name    = "backend-subnet"
  project = google_project.project.project_id

  ip_cidr_range = "10.1.0.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance_template" "backend" {
  project      = google_project.project.project_id
  name         = "${var.lab_name}-backend-it"
  machine_type = "f1-micro"
  region       = var.region

  tags = ["backend-instance", "open-ssh"]
  disk {
    source_image = "debian-cloud/debian-9"
  }

  network_interface {
    network            = google_compute_network.vpc_network.self_link
    subnetwork         = google_compute_subnetwork.backend.name
    subnetwork_project = google_project.project.project_id

    access_config {
      // Ephemeral IP
    }
  }
  service_account {
    email  = google_service_account.backend.email
    scopes = []
  }
}

resource "google_compute_region_instance_group_manager" "backend" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-backend-it-group"

  base_instance_name = "${var.lab_name}-backend-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.backend.id
  }
}

resource "google_compute_region_autoscaler" "backend" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-backend-autoscaler"
  region  = var.region
  target  = google_compute_region_instance_group_manager.backend.id

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 3
  }
}
