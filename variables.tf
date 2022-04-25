##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter. This prefix will be prepended to any resources provisioned by this template."
  type        = string
  default     = "ez-multitier"

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Name of existing resource group where all infrastructure will be provisioned"
  type        = string
  default     = "asset-development"

  validation {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
  }
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = ["ez-vpc", "multitier-vpc"]
}

##############################################################################


##############################################################################
# Subnet Variables
##############################################################################

variable "tier_names" {
  description = "Name of each tier in the VPC. Each tier will be created with one subnet in each zone."
  type        = list(string)
  default     = ["management", "development", "production"]

  validation {
    error_message = "Each VPC tier must have a unique name."
    condition     = length(var.tier_names) == length(distinct(var.tier_names))
  }
}

variable "use_public_gateways" {
  description = "List of subnet tiers to attach public gateways. A public gateway will be created in each zone if any VPC is in this list."
  type        = list(string)
  default     = ["production"]

  validation {
    error_message = "Each VPC tier must be unique in the list."
    condition     = length(var.use_public_gateways) == length(distinct(var.use_public_gateways))
  }
}

variable "allow_inbound_traffic" {
  description = "Create a rule in each tier in this list to allow all inbound traffic."
  type        = list(string)
  default     = ["production"]

  validation {
    error_message = "Each VPC tier must be unique in the list."
    condition     = length(var.allow_inbound_traffic) == length(distinct(var.allow_inbound_traffic))
  }
}

variable "add_cluster_rules" {
  description = "Create a rule in each tier in this list to allow rules to allow the creation of IBM managed clusters."
  type        = list(string)
  default     = ["production", "workload"]

  validation {
    error_message = "Each VPC tier must be unique in the list."
    condition     = length(var.add_cluster_rules) == length(distinct(var.add_cluster_rules))
  }
}

variable "classic_access" {
  description = "Add the ability to access classic infrastructure from your VPC."
  type        = bool
  default     = false
}

variable "override" {
  description = "Override any values with `override.json` JSON to create a completely custom network."
  type        = bool
  default     = true
}

##############################################################################