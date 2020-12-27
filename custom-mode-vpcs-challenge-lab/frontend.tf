resource "google_compute_subnetwork" "frontend" {
  name    = "frontend-subnet"
  project = google_project.project.project_id

  ip_cidr_range = "10.2.0.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance_template" "frontend" {
  project      = google_project.project.project_id
  name         = "${var.lab_name}-frontend-it"
  machine_type = "f1-micro"
  region       = var.region

  tags = ["frontend-instance", "open-ssh"]
  disk {
    source_image = "debian-cloud/debian-9"
  }

  network_interface {
    network            = google_compute_network.vpc_network.self_link
    subnetwork         = google_compute_subnetwork.frontend.name
    subnetwork_project = google_project.project.project_id

    access_config {
      // Ephemeral IP
    }
  }
  service_account {
    email  = google_service_account.frontend.email
    scopes = []
  }
}

resource "google_compute_region_instance_group_manager" "frontend" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-frontend-it-group"

  base_instance_name = "${var.lab_name}-frontend-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.frontend.id
  }
}

resource "google_compute_region_autoscaler" "frontend" {
  project = google_project.project.project_id
  name    = "${var.lab_name}-frontend-autoscaler"
  region  = var.region
  target  = google_compute_region_instance_group_manager.frontend.id

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 3
  }
}
