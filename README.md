# Easy Multitier VPC

This template allows users to easily create a VPC with three tiers, each tier having one subnet in each of three zones with very few inputs needed by the user to quikly start testing on IBM Cloud. 

## Default Configuration

![ez vpc](./.docs/mt-vpc.png)

The defaults of this module can be [overridden](#overriding-variables) with JSON to allow for a fully cusomizable VPC environment.

## Table of Contents

1. [Module Variables](#module-variables)
1. [VPC and Subnets](#vpc-and-subnets)
2. [Network ACL](#nettwork-access-control-list)
3. [Public Gateways](#public-gateways)
4. [Overriding Variables](#overriding-variables)

## Module Variables

Name                    | Type         | Description                                                                                                                               | Sensitive | Default
----------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------------------------------------------
ibmcloud_api_key        | string       | The IBM Cloud platform API key needed to deploy IAM enabled resources.                                                                    | true      | 
prefix                  | string       | A unique identifier for resources. Must begin with a letter. This prefix will be prepended to any resources provisioned by this template. |           | `ez-multizone`
region                  | string       | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions.                   |           | `us-south`
resource_group          | string       | Name of existing resource group where all infrastructure will be provisioned                                                              |           | `asset-development`
tags                    | list(string) | List of tags to apply to resources created by this module.                                                                                |           | `["ez-vpc", "multitier-vpc"]`
tier_names              | list(string) | Name of each tier in the VPC. Each tier will be created with one subnet in each zone.                                                     |           | `["management", "development", "production"]`
use_public_gateways     | list(string) | List of subnet tiers to attach public gateways. A public gateway will be created in each zone if any VPC is in this list.                 |           | `["production"]`
allow_inbound_traffic   | list(string) | Create a rule in each tier in this list to allow all inbound traffic.                                                                     |           | `[]`
add_cluster_rules       | list(string) | Create a rule in each tier in this list to allow rules to allow the creation of IBM managed clusters.                                     |           | `["production", "workload"]`
classic_access          | bool         | Add the ability to access classic infrastructure from your VPC.                                                                           |           | `false`
override_json           | string       | Override any values with JSON to create a completely custom network. All quotation marks must be correctly escaped.                       |           | `"{}"`

---

## VPC and Subnets

### VPC

This module creates a single VPC in one IBM Cloud Region. The VPC can optionally be given access to Classic Infrastructure resources using the `classic_access` variable.

### Subnets

This module creates three tiers of subnets, each with one subnet in each of three zones.

#### Management Tier

Zone | Subnet CIDR
-----|-------------
1    | 10.10.10.0/24
2    | 10.20.10.0/24
3    | 10.30.10.0/24

#### Development Tier

Zone | Subnet CIDR
-----|-------------
1    | 10.40.10.0/24
2    | 10.50.10.0/24
3    | 10.60.10.0/24

#### Production Tier

Zone | Subnet CIDR
-----|-------------
1    | 10.70.10.0/24
2    | 10.80.10.0/24
3    | 10.90.10.0/24

---

## Network Access Control List

A single network ACL is created for each VPC tier. Dynamic rules are created to allow all traffic from within a single ACL.

### Management Network Access Control Rules

The following network rules are automatically created to allow the management subnet tier to communicate within the tier and with the development and production tiers.

Source        | Destination   | Direction  | Allow / Deny
--------------|---------------|------------|--------------
10.10.10.0/24 | Any           | Inbound    | Allow
10.20.10.0/24 | Any           | Inbound    | Allow
10.30.10.0/24 | Any           | Inbound    | Allow
10.40.10.0/24 | Any           | Inbound    | Allow
10.50.10.0/24 | Any           | Inbound    | Allow
10.60.10.0/24 | Any           | Inbound    | Allow
10.70.10.0/24 | Any           | Inbound    | Allow
10.80.10.0/24 | Any           | Inbound    | Allow
10.90.10.0/24 | Any           | Inbound    | Allow
Any           | 10.10.10.0/24 | Outbound   | Allow
Any           | 10.20.10.0/24 | Outbound   | Allow
Any           | 10.30.10.0/24 | Outbound   | Allow
Any           | 10.40.10.0/24 | Outbound   | Allow
Any           | 10.50.10.0/24 | Outbound   | Allow
Any           | 10.60.10.0/24 | Outbound   | Allow
Any           | 10.70.10.0/24 | Outbound   | Allow
Any           | 10.80.10.0/24 | Outbound   | Allow
Any           | 10.90.10.0/24 | Outbound   | Allow
Any           | Any           | Outbound   | Allow

### Development Network Access Control Rules

The following rules are created to allow the Development network to communicate to communicate within the tier and with the management tier.

Source        | Destination   | Direction  | Allow / Deny
--------------|---------------|------------|--------------
10.10.10.0/24 | Any           | Inbound    | Allow
10.20.10.0/24 | Any           | Inbound    | Allow
10.30.10.0/24 | Any           | Inbound    | Allow
10.40.10.0/24 | Any           | Inbound    | Allow
10.50.10.0/24 | Any           | Inbound    | Allow
10.60.10.0/24 | Any           | Inbound    | Allow
Any           | 10.10.10.0/24 | Outbound   | Allow
Any           | 10.20.10.0/24 | Outbound   | Allow
Any           | 10.30.10.0/24 | Outbound   | Allow
Any           | 10.40.10.0/24 | Outbound   | Allow
Any           | 10.50.10.0/24 | Outbound   | Allow
Any           | 10.60.10.0/24 | Outbound   | Allow
Any           | Any           | Outbound   | Allow

### Production Network Access Control Rules

The following rules are created to allow the production network to communicate to communicate within the tier and with the management tier.

Source        | Destination   | Direction  | Allow / Deny
--------------|---------------|------------|--------------
10.10.10.0/24 | Any           | Inbound    | Allow
10.20.10.0/24 | Any           | Inbound    | Allow
10.30.10.0/24 | Any           | Inbound    | Allow
10.70.10.0/24 | Any           | Inbound    | Allow
10.80.10.0/24 | Any           | Inbound    | Allow
10.90.10.0/24 | Any           | Inbound    | Allow
Any           | 10.10.10.0/24 | Outbound   | Allow
Any           | 10.20.10.0/24 | Outbound   | Allow
Any           | 10.30.10.0/24 | Outbound   | Allow
Any           | 10.70.10.0/24 | Outbound   | Allow
Any           | 10.80.10.0/24 | Outbound   | Allow
Any           | 10.90.10.0/24 | Outbound   | Allow
Any           | Any           | Outbound   | Allow

### Additional Access Control Rules

- To dynamically create allow rules to allow IBM Managed Clusters, add a tier's name to the  `add_cluster_rules` variable list.
- To create a rule to allow all inbound traffic to your VPC,  add a tier's name to the  `allow_inbound_traffic` variable list. 

---

## Public Gateways

Optionally, a public gateway can be added to each of the three subnets by adding a tier's name to the  `use_public_gateways` variable list. If the list is empty, no public gateways will be provisioned.

---

## Overriding Variables

This template uses a [vpc module](./ez_vpc/vpc) to create the network architecture. A complete custom network architecture can be created from this template by passing stringified `json` data into the `override_json` variable. For an example of a valid JSON file, see [override-json.json](./override-json.json). Stringified, the JSON looks like this:

```
"{\"vpc_name\":\"override-vpc\",\"classic_access\":true,\"use_manual_address_prefixes\":false,\"default_network_acl_name\":\"override-acl-name\",\"default_security_group_name\":\"override-sg-name\",\"subnets\":{\"zone-1\":[{\"acl_name\":\"override-acl\",\"cidr\":\"10.20.10.0/24\",\"name\":\"override-1\",\"public_gateway\":true},{\"acl_name\":\"bastion-subnet-acl\",\"cidr\":\"10.10.10.0/24\",\"name\":\"bastion\",\"public_gateway\":false}],\"zone-2\":[{\"acl_name\":\"override-acl\",\"cidr\":\"10.80.10.0/24\",\"name\":\"override-subnet-2\",\"public_gateway\":false}],\"zone-3\":[{\"acl_name\":\"override-acl\",\"cidr\":\"10.30.90.0/24\",\"name\":\"subnet-oberride-3\",\"public_gateway\":false}]},\"network_acls\":[{\"name\":\"override-acl\",\"add_cluster_rules\":true,\"rules\":[{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"outbound\",\"name\":\"allow-outbound-8080\",\"source\":\"0.0.0.0/0\",\"tcp\":{\"port_min\":8080,\"port_max\":8080}},{\"action\":\"allow\",\"destination\":\"10.10.10.0/24\",\"direction\":\"outbound\",\"name\":\"allow-all-bastion-outbound\",\"source\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"source\":\"10.10.10.0/24\",\"direction\":\"inbound\",\"name\":\"allow-all-bastion-inbound\",\"destination\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-zone-1\",\"source\":\"10.20.10.0/24\"},{\"action\":\"allow\",\"destination\":\"10.20.10.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-zone-1\",\"source\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-inbound-zone-2\",\"source\":\"10.80.10.0/24\"},{\"action\":\"allow\",\"destination\":\"10.80.10.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-2\",\"source\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-inbound-zone-3\",\"source\":\"10.30.90.0/24\"},{\"action\":\"allow\",\"destination\":\"10.30.90.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-zone-3\",\"source\":\"0.0.0.0/0\"}]},{\"name\":\"bastion-subnet-acl\",\"rules\":[{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-zone-1\",\"source\":\"10.20.10.0/24\"},{\"action\":\"allow\",\"destination\":\"10.20.10.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-zone-1\",\"source\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-inbound-zone-2\",\"source\":\"10.80.10.0/24\"},{\"action\":\"allow\",\"destination\":\"10.80.10.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-2\",\"source\":\"0.0.0.0/0\"},{\"action\":\"allow\",\"destination\":\"0.0.0.0/0\",\"direction\":\"inbound\",\"name\":\"allow-inbound-zone-3\",\"source\":\"10.30.90.0/24\"},{\"action\":\"allow\",\"destination\":\"10.30.90.0/24\",\"direction\":\"outbound\",\"name\":\"allow-outbound-zone-3\",\"source\":\"0.0.0.0/0\"}]}],\"security_group_rules\":[{\"name\":\"allow-all-tcp-8080-inbound\",\"direction\":\"inbound\",\"remote\":\"0.0.0.0/0\"}],\"vpn_gateways\":[]}"
```

For more information about configuring the module see the [vpc module](./ez_vpc/vpc) for a detailed README and a full list of accepted variables.