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

locals {
  vm_image_map = {
    stage = data.yandex_compute_image.image.id
    prod = data.yandex_compute_image.image.id
  }

  vm_count_map = {
    stage = 1
    prod = 2
  }
}

resource "yandex_compute_instance" "vm_count" {
  name = "${var.name}-count-${terraform.workspace}"
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
      image_id = local.vm_image_map[terraform.workspace]
      type = var.yc_boot_disk
      size = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.yc_subnet_id
    nat = var.yc_network_nat
  }

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/abeletsky-gmail-com.pub")}"
  }

  count = local.vm_count_map[terraform.workspace]
}

resource "yandex_compute_instance" "vm_foreach" {
  for_each = local.vm_image_map

  name = "${var.name}-for-each-${each.key}"
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
      image_id = each.value
      type = var.yc_boot_disk
      size = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.yc_subnet_id
    nat = var.yc_network_nat
  }

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/abeletsky-gmail-com.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
