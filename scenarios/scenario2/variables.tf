variable "username" {}
variable "password" {}
variable "domain_name" {}
variable "tenant_name" {}

variable "postfix" {}
variable "net_address" {}
variable "region" {}
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}

variable "psql_version" {}
variable "psql_port" {}
variable "psql_password" {}

variable "public_key" {
  default = null
}
