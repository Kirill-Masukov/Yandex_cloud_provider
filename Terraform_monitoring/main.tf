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

resource "yandex_compute_instance" "my-vm-2" {
  name        = "vm-monitoring"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8auuc4tekngm"
    }
  }

  network_interface {
    subnet_id = "e9b7h1foif5bmi"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = "dns8ft4tm9u7hs"
  name    = "monitoring.kirill.ru."
  type    = "A"
  ttl     = 200
  data    = [(yandex_compute_instance.my-vm-2.network_interface.0.nat_ip_address)]
}

resource "yandex_dns_recordset" "rs3" {
  zone_id = "dns8ft4tm9u7hs"
  name    = "grafana.kirill.ru."
  type    = "A"
  ttl     = 200
  data    = [(yandex_compute_instance.my-vm-2.network_interface.0.nat_ip_address)]
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.my-vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.my-vm-2.network_interface.0.nat_ip_address
}

