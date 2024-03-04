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

resource "yandex_compute_instance" "my-vm-1" {
  name        = "vm-service"
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
    subnet_id = yandex_vpc_subnet.my-sn-1.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_network" "my-nw-1" {
  name = "my-nw-1"
}

resource "yandex_vpc_subnet" "my-sn-1" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-nw-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_lb_target_group" "my-lb-tg-1" {
  name      = "my-target-group-1"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.my-sn-1.id}"
    address   = "${yandex_compute_instance.my-vm-1.network_interface.0.ip_address}"
  }
}

resource "yandex_lb_network_load_balancer" "my-nw-lb-1" {
  name = "load-balancer-1"

  listener {
    name = "my-listener-1"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.my-lb-tg-1.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
      }
    }
  }
}

resource "yandex_dns_zone" "zone1" {
  name = "my-zone-1"
  zone = "kirill.ru."
  public = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "lb.kirill.ru."
  type    = "A"
  ttl     = 200
  data    = [(yandex_lb_network_load_balancer.my-nw-lb-1.listener[*].external_address_spec[*].address)[0][0]]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.my-vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.my-vm-1.network_interface.0.nat_ip_address
}

output "my_balancer_ip_address" {
  value = yandex_lb_network_load_balancer.my-nw-lb-1.listener
}
