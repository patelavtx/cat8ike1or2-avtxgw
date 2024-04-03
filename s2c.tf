
#---------------------  avtx transit external conn  ikev1 ---------------
/*
resource "aviatrix_transit_external_device_conn" "avx_tx-csr_connike1" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output  
  vpc_id                    = module.mc-transit.transit_gateway.vpc_id
  connection_name           = "${var.csr_name}-${module.mc-transit.transit_gateway.gw_name}"
  gw_name                   = module.mc-transit.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = module.mc-transit.transit_gateway.local_as_number
  bgp_remote_as_num         = var.csr_asn
# taken from csr.tf deployment
  remote_gateway_ip         = azurerm_public_ip.csr_pip.ip_address 
  pre_shared_key            = var.ipsec_psk
  phase1_local_identifier = "public_ip"
  phase1_remote_identifier = [local.phase1_remote_identifier]
  enable_ikev2              = "false"
  local_tunnel_cidr         = "${local.avtxapipa1}, ${local.avtxapipa2}"
  remote_tunnel_cidr        = "${local.csrapipa1}, ${local.csrapipa2}"
  depends_on = [
    azurerm_linux_virtual_machine.csr
  ]
}
*/


#---------------------  avtx transit external conn  ikev2 ---------------

resource "aviatrix_transit_external_device_conn" "avx_tx-csr_connike2" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output  
  vpc_id                    = module.mc-transit.transit_gateway.vpc_id
  connection_name           = "${var.csr_name}-${module.mc-transit.transit_gateway.gw_name}"
  gw_name                   = module.mc-transit.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = module.mc-transit.transit_gateway.local_as_number
  bgp_remote_as_num         = var.csr_asn
# taken from csr.tf deployment
  remote_gateway_ip         = azurerm_public_ip.csr_pip.ip_address 
  pre_shared_key            = var.ipsec_psk
  phase1_local_identifier = "public_ip"
  phase1_remote_identifier = [local.phase1_remote_identifier]    # used public ip
  enable_ikev2              = "true"
  local_tunnel_cidr         = "${local.avtxapipa1}/30, ${local.avtxapipa2}/30"
  remote_tunnel_cidr        = "${local.csrapipa1}/30, ${local.csrapipa2}/30"
  depends_on = [
    azurerm_linux_virtual_machine.csr
  ]
}
