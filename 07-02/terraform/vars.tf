variable "yc_cloud" {
  default = "b1gss4s7u9mos89m19gn"
}
variable "yc_folder_id" {
  default = "b1gjc6s8ee54eedsvb9o"
}
variable "yc_zone" {
  default = "ru-central1-a"
}
variable "yc_network_id" {
  default = "enp5ojui0qmtdq5ab9t2"
}
variable "yc_subnet_id" {
  default = "e9bnq0s714tmjo39791g"
}
variable "yc_network_nat" {
  default = "false"
}
variable "yc_boot_disk" {
  default = "network-hdd"
}
variable "yc_platform_id" {
  default = "standard-v1"
}
variable "yc_image_family" {
  default = "ubuntu-2004-lts"
}

variable "name" {
  default = "07-02"
}
variable "description" {
  default = "Homework 07-02"
}
variable "host" {
  default = "netology-07-02"
}
variable "user" {
  default = "user"
}
variable "cores" {
  default = 2
}
variable "yc_core_fraction" {
  default = 20
}
variable "memory" {
  default = 4
}
variable "disk_size" {
  default = "20"
}
