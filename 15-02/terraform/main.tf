# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
#      version = "0.80.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id  = var.yc_cloud
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# VPC Network
resource "yandex_vpc_network" "netology" {
  name = "netology"
}

# VPC Subnet Public
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]

  depends_on = [
    yandex_vpc_network.netology
  ]
}

# NAT
resource "yandex_compute_instance" "nat" {
  name = "nat"
  platform_id = var.yc_platform_id

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_nat_image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "user:${file("abeletsky-gmail-com.pub")}"
  }

  depends_on = [
    yandex_vpc_subnet.public
  ]
}

# Service Account
resource "yandex_iam_service_account" "images" {
  name = "images"
}

# Permissions for the Service Account
resource "yandex_resourcemanager_folder_iam_member" "images-role" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.images.id}"
}

# Static Access Keys
resource "yandex_iam_service_account_static_access_key" "images-static-key" {
  service_account_id = yandex_iam_service_account.images.id
}

# Object Storage
resource "yandex_storage_bucket" "images" {
  bucket = var.yc_bucket_name
  acl    = "public-read"
  access_key = yandex_iam_service_account_static_access_key.images-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.images-static-key.secret_key
}

# Image in Object Storage
resource "yandex_storage_object" "lake" {
  bucket = var.yc_bucket_name
  key    = "lake"
  source = "lake.jpg"
  access_key = yandex_iam_service_account_static_access_key.images-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.images-static-key.secret_key

  depends_on = [
    yandex_storage_bucket.images,
    yandex_resourcemanager_folder_iam_member.images-role
  ]
}

# VM
resource "yandex_compute_instance" "vm-public" {
  count = var.vm_lamp_count

  name = "vm-public-${count.index}"
  platform_id = var.yc_platform_id

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_vm_lamp_image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true
  }

  metadata = {
    user-data = file("cloud-config-${count.index}.yaml")
  }
}

# Target Group
resource "yandex_lb_target_group" "public" {
  name = "public"

  target {
    subnet_id = yandex_vpc_subnet.public.id
    address   = yandex_compute_instance.vm-public[0].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.public.id
    address   = yandex_compute_instance.vm-public[1].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.public.id
    address   = yandex_compute_instance.vm-public[2].network_interface[0].ip_address
  }
}

# Network Load Balancer
resource "yandex_lb_network_load_balancer" "public" {
  name = "public"

  listener {
    name = "listener"
    port = 80
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.public.id

    healthcheck {
      name = "vm-public-http-healthcheck"
      http_options {
        port = 80
      }
    }
  }
}
