##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC
##############################################################################

module "vpc" {
  source                      = "./vpc"
  resource_group_id           = data.ibm_resource_group.resource_group.id
  region                      = var.region
  tags                        = var.tags
  prefix                      = local.env.prefix
  vpc_name                    = local.env.vpc_name
  classic_access              = local.env.classic_access
  network_acls                = local.env.network_acls
  use_public_gateways         = local.env.use_public_gateways
  subnets                     = local.env.subnets
  use_manual_address_prefixes = local.env.use_manual_address_prefixes
  default_network_acl_name    = local.env.default_network_acl_name
  default_security_group_name = local.env.default_security_group_name
  default_routing_table_name  = local.env.default_routing_table_name
  address_prefixes            = local.env.address_prefixes
  routes                      = local.env.routes
  vpn_gateways                = local.env.vpn_gateways
}

##############################################################################