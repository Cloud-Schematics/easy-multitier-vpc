##############################################################################
# Dynamic Config
##############################################################################

locals {
  tiers = {
    for tier in var.tier_names :
    (tier) => {
      zone-1 = contains(var.allow_inbound_traffic, tier) ? [
        {
          name           = "${tier}-zone-1"
          cidr           = "10.${1 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        },
        {
          name = "allow-all"
          cidr = "0.0.0.0/0"
        }
        ] : [
        {
          name           = "${tier}-zone-1"
          cidr           = "10.${1 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ],
      zone-2 = [
        {
          name           = "${tier}-zone-2"
          cidr           = "10.${2 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ],
      zone-3 = [
        {
          name           = "${tier}-zone-3"
          cidr           = "10.${3 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ]
    }
  }
}

module "dynamic_acl_allow_rules" {
  for_each = local.tiers
  source   = "./dynamic_acl_allow_rules"
  subnets  = each.value
  prefix   = var.prefix
}

##############################################################################
# Local configuration
##############################################################################

locals {
  override = jsondecode(var.override_json)

  ##############################################################################
  # VPC config
  ##############################################################################
  config = {
    vpc_name = "vpc"
    prefix   = var.prefix
    ##############################################################################
    # Subnets
    ##############################################################################
    subnets = {
      zone-1 = [
        for tier in var.tier_names :
        {
          name           = "${tier}-zone-1"
          cidr           = "10.${1 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ],
      zone-2 = [
        for tier in var.tier_names :
        {
          name           = "${tier}-zone-2"
          cidr           = "10.${2 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ],
      zone-3 = [
        for tier in var.tier_names :
        {
          name           = "${tier}-zone-3"
          cidr           = "10.${3 + (index(var.tier_names, tier) * 3)}0.10.0/24"
          public_gateway = contains(var.use_public_gateways, tier)
          acl_name       = "${tier}-acl"
        }
      ]

    }
    ##############################################################################

    ##############################################################################
    # ACL rules
    ##############################################################################
    acl_rules = {
      for tier in var.tier_names :
      (tier) => concat(module.dynamic_acl_allow_rules[tier].rules, [
        {
          name        = "allow-all-outbound"
          action      = "allow"
          direction   = "outbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        }
      ])
    }

    network_acls = [
      for tier in var.tier_names :
      {
        name = "${tier}-acl"
        rules = tier == "management" ? distinct(
          flatten([
            for allow_rules in var.tier_names :
            module.dynamic_acl_allow_rules[allow_rules].rules
          ])
          ) : distinct(
          flatten([
            for allow_rules in var.tier_names :
            module.dynamic_acl_allow_rules[allow_rules].rules if allow_rules == tier || allow_rules == "management"
          ])
        )
        add_cluster_rules = contains(var.add_cluster_rules, tier)
      }
    ]

    ##############################################################################

    ##############################################################################
    # Public Gateways
    ##############################################################################
    use_public_gateways = {
      zone-1 = length(var.use_public_gateways) > 0 ? true : false
      zone-2 = length(var.use_public_gateways) > 0 ? true : false
      zone-3 = length(var.use_public_gateways) > 0 ? true : false
    }
    ##############################################################################

    ##############################################################################
    # Default VPC Security grop rules
    ##############################################################################
    security_group_rules = [
      {
        name      = "allow-all-inbound"
        direction = "inbound"
        remote    = "0.0.0.0/0"
      }
    ]
    ##############################################################################
  }

  env = {
    prefix                      = lookup(local.override, "prefix", var.prefix)
    vpc_name                    = lookup(local.override, "vpc_name", local.config.vpc_name)
    classic_access              = lookup(local.override, "classic_access", var.classic_access)
    network_acls                = lookup(local.override, "network_acls", local.config.network_acls)
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

  string = "\"${jsonencode(local.env)}\""
}

##############################################################################

##############################################################################
# Convert Environment to escaped readable string
##############################################################################

data "external" "format_output" {
  program = ["python3", "${path.module}/scripts/output.py", local.string]
}

##############################################################################