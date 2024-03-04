terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  ztoken     = "y0_AgAAAABqT1WnAATuwQAADiI_aB6mclAmR9aXDf3Bkut5-lk"
  cloud_id  = "b1go4n5hoo0u8ji"
  folder_id = "b1gj2d8qm181ihre"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance_group" "group1" {
  name                = "my-ig"
  folder_id           = "b1gj2d8qm181ihre"
  service_account_id  = "ajevklrcs60nqm"
  deletion_protection = "false"
  instance_template {
    platform_id = "standard-v1"
    hostname = "asg-{instance.index}"
    name = "asg-{instance.index}"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
      image_id = "fd8auuc4tekngm"
    }
  }
    network_interface {
      subnet_ids = ["e9b78cdvfvear"]
      nat = true
  }

    metadata = {
      ssh-keys = "ubuntu:${file("~.ssh/id_ed25519.pub")} \nroot:${file("~.ssh/id_ed25519.pub")}"
    }

    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    auto_scale {
      initial_size = 1
      measurement_duration = 60
      cpu_utilization_target = 30
      min_zone_size = 1
      max_size = 2
      stabilization_duration = 60      
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
}
