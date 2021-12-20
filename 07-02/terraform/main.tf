terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

# Provider
provider "yandex" {
  cloud_id  = var.yc_cloud
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

data "yandex_compute_image" "image" {
  family = var.yc_image_family
}

resource "yandex_compute_instance" "vm" {
  name = var.name
  description = var.description
  folder_id = var.yc_folder_id
  zone = var.yc_zone
  hostname = var.host
  platform_id = var.yc_platform_id

  resources {
    cores  = var.cores
    memory = var.memory
    core_fraction = var.yc_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type = var.yc_boot_disk
      size = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.yc_subnet_id
    nat       = var.yc_network_nat
  }

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/abeletsky-gmail-com.pub")}"
  }
}
