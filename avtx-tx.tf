
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest

# Step1 - deploy transit
module "mc-transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.6.0"
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
  enable_transit_firenet = true
  tags  =  var.tags
}


module "firenet_1" {
  source         = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version        = "v1.6.0"
  transit_module = module.mc-transit
  custom_fw_names = ["${local.fw1}", "${local-fw2}"]
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  bootstrap_storage_name_1 = var.bootstrap_storage_name_1             # should exist   ; 
  file_share_folder_1 = var.file_share_folder_1                   
  storage_access_key_1 = var.storage_access_key_1
  #inspection_enabled = ""         # default =true
  #keep_alive_via_lan_interface_enabled = "true"            # see readme.txt
  #egress_enabled = "true"
}

# Vendor integration for PA NEEDed for Azure *****
# added delay to allow fw interfaces to be ready for vendor integration

resource "time_sleep" "wait_90_seconds" {
  create_duration = "90s"
  depends_on = [ module.firenet_1 ]
}


# data integration
data "aviatrix_firenet_vendor_integration" "fw1" {
  vpc_id        = module.mc-transit.transit_gateway.vpc_id
  instance_id   = module.firenet_1.aviatrix_firewall_instance[0].instance_id
  vendor_type   = "Palo Alto Networks VM-Series"  # "Generic", "Palo Alto Networks VM-Series", "Aviatrix FQDN Gateway" and "Fortinet FortiGate"
  public_ip     = module.firenet_1.aviatrix_firewall_instance[0].public_ip
  username      = var.fwuser                      # REST_API user or admin for PA
  password      = var.fwpasswd
  firewall_name = module.firenet_1.aviatrix_firewall_instance[0].firewall_name
  save          = true
  #synchronize   = true # "save" and "synchronize" cannot be invoked at the same time
  depends_on = [ time_sleep.wait_90_seconds ]
}



#fw2
data "aviatrix_firenet_vendor_integration" "fw2" {
  vpc_id        = module.mc-transit.transit_gateway.vpc_id
  instance_id   = module.firenet_1.aviatrix_firewall_instance[1].instance_id
  vendor_type   = "Palo Alto Networks VM-Series"         # "Generic", "Palo Alto Networks VM-Series", "Aviatrix FQDN Gateway" and "Fortinet FortiGate"
  public_ip     = module.firenet_1.aviatrix_firewall_instance[1].public_ip
  username      = var.fwuser                            # REST_API user or admin for PA
  password      = var.fwpasswd
  firewall_name = module.firenet_1.aviatrix_firewall_instance[1].firewall_name
  save          = true
  #synchronize   = true # "save" and "synchronize" cannot be invoked at the same time
  depends_on = [ time_sleep.wait_90_seconds ]
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
