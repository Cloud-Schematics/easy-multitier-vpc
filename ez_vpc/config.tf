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

  ##############################################################################
  # Create ACLS
  ##############################################################################
  acls = [
    for tier in var.tier_names :
    {
      name              = "${tier}-acl"
      rules             = tier == "management" ? distinct(
        flatten([
          for allow_rules in var.tier_names:
          module.dynamic_acl_allow_rules[allow_rules].rules
        ])
      ) : distinct(
        flatten([
          module.dynamic_acl_allow_rules[tier].rules

        ])
      )
      add_cluster_rules = contains(var.add_cluster_rules, tier)
    }
  ]
  ##############################################################################
}

##############################################################################