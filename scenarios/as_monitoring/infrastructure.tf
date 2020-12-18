locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace

  key_pair = {
    public_key = var.public_key
    key_name = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "resources" {
  source = "./resources"

  ecs_flavor = var.ecs_flavor
  availability_zone = var.availability_zone
  host_image = var.host_image
  disc_volume = var.disc_volume
  key_pair = local.key_pair

  lb_monitor = module.loadbalancer.monitor
  lb_pool = module.loadbalancer.pool
  net_address = var.addr_3_octets
  subnet_id = var.subnet_id
  network_id = var.network_id
  router_id = var.router_id
  scenario = var.scenario
  controller_ip = var.controller_ip
}


module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances = module.resources.as_instance_ip
  net_address = var.addr_3_octets
  subnet_id = var.subnet_id
  scenario = var.scenario
  workspace_prefix = local.workspace_prefix
}

output "lb_instance_ip" {
  value = module.loadbalancer.loadbalancer_ip
}

output "as_instance_ip" {
  value = module.resources.as_instance_ip
}
