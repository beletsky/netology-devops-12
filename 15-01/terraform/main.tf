# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
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
}

# VM with public access
resource "yandex_compute_instance" "vm-public" {
  name = "vm-public"
  platform_id = var.yc_platform_id

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_vm_image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true
  }

  metadata = {
    ssh-keys = "user:${file("abeletsky-gmail-com.pub")}"
  }
}

# Route Table
resource "yandex_vpc_route_table" "private-to-nat" {
  network_id = yandex_vpc_network.netology.id

  depends_on = [
    yandex_compute_instance.nat
  ]

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat.network_interface[0].ip_address
  }
}

# VPC Subnet Private
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private-to-nat.id
}

# VM with private access
resource "yandex_compute_instance" "vm-private" {
  name = "vm-private"
  platform_id = var.yc_platform_id

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_vm_image_id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private.id
    nat        = false
  }

  metadata = {
    ssh-keys = "user:${file("abeletsky-gmail-com.pub")}"
  }
}
