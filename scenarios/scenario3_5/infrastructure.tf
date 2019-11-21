
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.postfix}"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.prefix}_kp"
  }
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = local.prefix
}

module "resources" {
  source = "./resources"
  prefix            = local.prefix
  ecs_image         = var.ecs_image
  availability_zone = var.availability_zone
  ecs_flavor        = var.ecs_flavor
  disc_volume       = var.disc_volume
  key_pair          = local.key_pair
  net_address       = var.addr_3_octets
  subnet            = module.network.subnet
  network           = module.network.network
}

output "out-scn3_5_target_fip" {
  value = module.resources.target_fip
}

output "out-out-scn3_5_initiator_fip" {
  value = module.resources.initiator_fip
}