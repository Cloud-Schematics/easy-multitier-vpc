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
  prefix                      = lookup(local.override, "prefix", var.prefix)
  vpc_name                    = lookup(local.override, "vpc_name", local.config.vpc_name)
  classic_access              = lookup(local.override, "classic_access", var.classic_access)
  network_acls                = lookup(local.override, "network_acls", local.acls)
  use_public_gateways         = lookup(local.override, "use_public_gateways", local.config.use_public_gateways)
  subnets                     = lookup(local.override, "subnets", local.config.subnets)
  use_manual_address_prefixes = lookup(local.override, "use_manual_address_prefixes", null)
  default_network_acl_name    = lookup(local.override, "default_network_acl_name", null)
  default_security_group_name = lookup(local.override, "default_security_group_name", null)
  default_routing_table_name  = lookup(local.override, "default_routing_table_name", null)
  address_prefixes            = lookup(local.override, "address_prefixes", null)
  routes                      = lookup(local.override, "routes", [])
  vpn_gateways                = lookup(local.override, "vpn_gateways", [])
}

##############################################################################