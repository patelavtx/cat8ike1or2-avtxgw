
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest

# Step1 - deploy transit
module "mc-transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.4.2"
  cloud = "Azure"        
  cidr = var.cidr
  region = var.region
  account = var.account
  # resource_group = var.rg   # rm for use in GH sourced module
  local_as_number = var.localasn
  insane_mode = "true"
  name = var.tx_gwname
  enable_advertise_transit_cidr = "true"
  enable_bgp_over_lan = "true"
  bgp_lan_interfaces_count = "1"
  enable_segmentation    = "true"
  tags  =  var.tags
}




# outputs

output "vpc" {
  description = "The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource."
  value       = module.mc-transit.vpc
}

output "transit_gateway" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway
  sensitive   = true
}