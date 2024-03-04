terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "y0_AgAAAABqT1WnAATuwQAADiI_aB6mclAmR9aXDf3Bkut5-lk"
  cloud_id  = "b1go4n5hoo0u8ji"
  folder_id = "b1gj2d8qm181ihre"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "my-vm-3" {
  name        = "vm-service-prod"
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

resource "yandex_lb_target_group" "my-lb-tg-2" {
  name      = "my-target-group-2"
  region_id = "ru-central1"

  target {
    subnet_id = "e9b7h1foif5bmi"
    address   = "${yandex_compute_instance.my-vm-3.network_interface.0.ip_address}"
  }
}

resource "yandex_lb_network_load_balancer" "my-nw-lb-2" {
  name = "load-balancer-2"

  listener {
    name = "my-listener-2"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.my-lb-tg-2.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
      }
    }
  }
}

resource "yandex_dns_recordset" "rs4" {
  zone_id = "dns8ft4tm9u7hs"
  name    = "lb-prod.kirill.ru."
  type    = "A"
  ttl     = 200
  data    = [(yandex_lb_network_load_balancer.my-nw-lb-2.listener[*].external_address_spec[*].address)[0][0]]
}

output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.my-vm-3.network_interface.0.ip_address
}

output "external_ip_address_vm_3" {
  value = yandex_compute_instance.my-vm-3.network_interface.0.nat_ip_address
}

output "my_balancer_ip_address" {
  value = yandex_lb_network_load_balancer.my-nw-lb-2.listener
}
