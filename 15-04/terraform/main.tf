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

# VPC network
resource "yandex_vpc_network" "netology" {
  name = "netology"
}

# VPC public subnets
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "public-c" {
  name           = "public-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

# NAT VM
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
    subnet_id  = yandex_vpc_subnet.public-a.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "user:${file("abeletsky-gmail-com.pub")}"
  }
}

# Route table
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

# VPC private subnets
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.40.0/24"]
  route_table_id = yandex_vpc_route_table.private-to-nat.id
}

resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.50.0/24"]
  route_table_id = yandex_vpc_route_table.private-to-nat.id
}

resource "yandex_vpc_subnet" "private-c" {
  name           = "private-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = ["192.168.60.0/24"]
  route_table_id = yandex_vpc_route_table.private-to-nat.id
}

#
# MySQL
#

# MySQL high-available cluster
resource "yandex_mdb_mysql_cluster" "netology" {
  name        = "netology"
  network_id  = yandex_vpc_network.netology.id
  environment = "PRESTABLE"
  version     = "8.0"

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-hdd"
    disk_size          = 20
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private-a.id
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private-b.id
  }

  host {
    zone      = "ru-central1-c"
    subnet_id = yandex_vpc_subnet.private-c.id
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours = 23
    minutes = 59
  }

  deletion_protection = true
}

# MySQL database
resource "yandex_mdb_mysql_database" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology.id
  name       = var.database_name
}

# MySQL user
resource "yandex_mdb_mysql_user" "netology" {
    cluster_id = yandex_mdb_mysql_cluster.netology.id
    name       = var.database_user
    password   = var.database_password

    global_permissions = ["PROCESS"]

    permission {
      database_name = yandex_mdb_mysql_database.netology.name
      roles         = ["ALL"]
    }

    authentication_plugin = "SHA256_PASSWORD"
}

#
# Kubernetes
#

# Service account for resources
resource "yandex_iam_service_account" "kubernetes" {
  name = "kubernetes"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-cluster-agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-image-puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-alb-editor" {
  folder_id = var.yc_folder_id
  role      = "alb.editor"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-vpc-public-admin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-certificate-download" {
  folder_id = var.yc_folder_id
  role      = "certificate-manager.certificates.downloader"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "kubernetes-compute-viewer" {
  folder_id = var.yc_folder_id
  role      = "compute.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}

# KMS key

# KMS Symmetric Key
resource "yandex_kms_symmetric_key" "kubernetes" {
  name              = "kubernetes"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}
resource "yandex_kms_symmetric_key_iam_binding" "kubernetes" {
  symmetric_key_id = yandex_kms_symmetric_key.kubernetes.id
  role             = "viewer"
  members          = [
    "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
  ]
}

# Kubernetes cluster
resource "yandex_kubernetes_cluster" "netology" {
  name = "netology"

  network_id = yandex_vpc_network.netology.id

  service_account_id      = yandex_iam_service_account.kubernetes.id
  node_service_account_id = yandex_iam_service_account.kubernetes.id

  release_channel = "STABLE"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kubernetes.id
  }

  master {
    version   = var.kubernetes_version
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public-a.zone
        subnet_id = yandex_vpc_subnet.public-a.id
      }

      location {
        zone      = yandex_vpc_subnet.public-b.zone
        subnet_id = yandex_vpc_subnet.public-b.id
      }

      location {
        zone      = yandex_vpc_subnet.public-c.zone
        subnet_id = yandex_vpc_subnet.public-c.id
      }
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.kubernetes-cluster-agent,
    yandex_resourcemanager_folder_iam_member.kubernetes-editor,
    yandex_resourcemanager_folder_iam_member.kubernetes-image-puller,
    yandex_resourcemanager_folder_iam_member.kubernetes-alb-editor,
    yandex_resourcemanager_folder_iam_member.kubernetes-vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.kubernetes-certificate-download,
    yandex_resourcemanager_folder_iam_member.kubernetes-compute-viewer,
    yandex_kms_symmetric_key_iam_binding.kubernetes
  ]
}

# Kubernetes node group
resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.netology.id
  name        = "netology"
  version     = var.kubernetes_version

  instance_template {
    platform_id = "standard-v2"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.private-a.id]
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      min = 3
      max = 6
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.private-a.zone
    }
  }
}
