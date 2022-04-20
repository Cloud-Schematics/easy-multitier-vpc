const tfxjs = require("tfxjs");
const tfx = new tfxjs("../", "ibmcloud_api_key");
const cidrRules = require("./cidr-rules.json");

tfx.plan("Easy Multitier VPC", () => {
  tfx.module("Easy VPC", "module.ez_vpc");
  tfx.module(
    "VPC Module",
    "module.ez_vpc.module.vpc",
    tfx.resource(
      "Development ACL",
      'ibm_is_network_acl.network_acl["development-acl"]',
      {
        name: "ez-multitier-development-acl",
        rules: cidrRules.development,
      }
    ),
    tfx.resource(
      "Management ACL",
      'ibm_is_network_acl.network_acl["management-acl"]',
      {
        name: "ez-multitier-management-acl",
        rules: cidrRules.management,
      }
    ),
    tfx.resource(
      "Production ACL",
      'ibm_is_network_acl.network_acl["production-acl"]',
      {
        name: "ez-multitier-production-acl",
        rules: cidrRules.production,
      }
    ),
    tfx.resource("Zone 1 Gateway", 'ibm_is_public_gateway.gateway["zone-1"]', {
      name: "ez-multitier-public-gateway-zone-1",
      zone: "us-south-1",
    }),
    tfx.resource("Zone 2 Gateway", 'ibm_is_public_gateway.gateway["zone-2"]', {
      name: "ez-multitier-public-gateway-zone-2",
      zone: "us-south-2",
    }),
    tfx.resource("Zone 3 Gateway", 'ibm_is_public_gateway.gateway["zone-3"]', {
      name: "ez-multitier-public-gateway-zone-3",
      zone: "us-south-3",
    }),
    tfx.resource(
      "Allow All Inbound Default Rule",
      'ibm_is_security_group_rule.default_vpc_rule["allow-all-inbound"]',
      {
        direction: "inbound",
        icmp: [],
        ip_version: "ipv4",
        remote: "0.0.0.0/0",
        tcp: [],
        udp: [],
      }
    ),
    tfx.resource(
      "Development Zone 1 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-development-zone-1"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.40.10.0/24",
        name: "ez-multitier-development-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Development Zone 2 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-development-zone-2"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.50.10.0/24",
        name: "ez-multitier-development-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Development Zone 3 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-development-zone-3"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.60.10.0/24",
        name: "ez-multitier-development-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource(
      "Management Zone 1 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-management-zone-1"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.10.10.0/24",
        name: "ez-multitier-management-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Management Zone 2 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-management-zone-2"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.20.10.0/24",
        name: "ez-multitier-management-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Management Zone 3 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-management-zone-3"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.30.10.0/24",
        name: "ez-multitier-management-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource(
      "Production Zone 1 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-production-zone-1"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.70.10.0/24",
        name: "ez-multitier-production-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Production Zone 2 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-production-zone-2"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.80.10.0/24",
        name: "ez-multitier-production-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Production Zone 3 Subnet",
      'ibm_is_subnet.subnet["ez-multitier-production-zone-3"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.90.10.0/24",
        name: "ez-multitier-production-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource("VPC", "ibm_is_vpc.vpc", {
      address_prefix_management: "manual",
      classic_access: false,
      name: "ez-multitier-vpc",
      tags: ["ez-vpc", "multitier-vpc"],
    }),
    tfx.resource(
      "Development Zone 1 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-development-zone-1"]',
      {
        cidr: "10.40.10.0/24",
        name: "ez-multitier-development-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Development Zone 2 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-development-zone-2"]',
      {
        cidr: "10.50.10.0/24",
        name: "ez-multitier-development-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Development Zone 3 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-development-zone-3"]',
      {
        cidr: "10.60.10.0/24",
        name: "ez-multitier-development-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource(
      "Management Zone 1 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-management-zone-1"]',
      {
        cidr: "10.10.10.0/24",
        name: "ez-multitier-management-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Management Zone 2 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-management-zone-2"]',
      {
        cidr: "10.20.10.0/24",
        name: "ez-multitier-management-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Management Zone 3 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-management-zone-3"]',
      {
        cidr: "10.30.10.0/24",
        name: "ez-multitier-management-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource(
      "Production Zone 1 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-production-zone-1"]',
      {
        cidr: "10.70.10.0/24",
        name: "ez-multitier-production-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Production Zone 2 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-production-zone-2"]',
      {
        cidr: "10.80.10.0/24",
        name: "ez-multitier-production-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Production Zone 3 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-multitier-production-zone-3"]',
      {
        cidr: "10.90.10.0/24",
        name: "ez-multitier-production-zone-3",
        zone: "us-south-3",
      }
    )
  );
});
// "module.ez_vpc.module.vpc.ibm_is_vpc_address_prefix.subnet_prefix[\"ez-multitier-production-zone-1\"]"
// "module.ez_vpc.module.vpc.ibm_is_vpc_address_prefix.subnet_prefix[\"ez-multitier-production-zone-1\"]"
