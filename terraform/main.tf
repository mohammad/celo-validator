provider "google" {
  project = "celo-303002"
  credentials = "../credentials/Celo-85fd921ccb33.json"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "celo-vm-instance"
  machine_type = "f1-micro"
  tags =        ["celo-vm-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    ssh-keys = "ansible:${file("../credentials/ansible.pub")}"
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "celo-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-rule" {
  name = "celo-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["celo-vm-instance"]
  source_ranges = ["0.0.0.0/0"]
}