locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "dns-infrastructure" {
  source = "./dns-infrastructure"

  ecs_image         = var.ecs_image
  availability_zone = var.availability_zone
  ecs_flavor        = var.ecs_flavor
  key_pair          = local.key_pair
  disc_volume       = var.disc_volume

  net_address = var.addr_3_octets
  subnet_id   = var.subnet_id
  network_id  = var.network_id
  router_id   = var.router_id
  scenario    = var.scenario
  region      = var.region
}

output "dns_instance_ip" {
  value = module.dns-infrastructure.dns_instance
}

output "dns_record_name" {
  value = module.dns-infrastructure.dns_record
}
