provider "google" {
  project = "celo-303002"
  credentials = "./credentials/Celo-85fd921ccb33.json"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "celo-vm-instance"
  machine_type = "f1-micro"
  tags =        ["celo-vm-instance"]


  provisioner "remote-exec" {
    connection { 
        type    = "ssh"
        user    = "ansible"
        timeout = "500s"
        private_key = file("./credentials/ansible")
        host = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
    }

    inline = [
        "sudo apt -y update",
        "sudo apt -y install git",
        "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >> /etc/apt/sources.list",
        "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367",
        "sudo apt -y install ansible"
    ]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    ssh-keys = "ansible:${file("./credentials/ansible.pub")}"
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