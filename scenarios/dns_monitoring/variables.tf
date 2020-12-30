variable "region" {
  default = "eu-de"
}
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {
  default = "dns_monitoring"
}
variable "public_key" {
  default = ""
}
variable "network_id" {}
variable "router_id" {}
variable "subnet_id" {}
variable "disc_volume" {
  type    = number
  default = 10
}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
  default = "192.168.0.0/16"
}

locals {
  scenario_subnet = cidrsubnet(network_cidr, 24, 6) # using same subnet, as csm_controller
}
