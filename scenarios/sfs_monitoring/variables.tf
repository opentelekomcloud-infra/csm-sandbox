variable "target_availability_zone" {}
variable "initiator_availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "scenario" {}
variable "public_key" {}
variable "disc_volume" {
  type    = number
  default = 10
}