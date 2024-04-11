resource "azurerm_resource_group" "csr_rg" {
  name     = var.csr_rg_name
  location = var.csr_rg_location
}

resource "azurerm_public_ip" "csr_pip" {
  name                = "${var.csr_name}-pip"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_virtual_network" "csr_vnet" {
  name                = "${var.csr_name}-vnet"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name

  address_space = [var.csr_vnet_address_space]

}



resource "azurerm_subnet" "csr_public" {
  resource_group_name  = azurerm_resource_group.csr_rg.name
  virtual_network_name = azurerm_virtual_network.csr_vnet.name
  name                 = "${var.csr_name}-public"
  address_prefixes     = [var.csr_public_subnet_address_space]
}

resource "azurerm_subnet" "csr_private" {
  resource_group_name  = azurerm_resource_group.csr_rg.name
  virtual_network_name = azurerm_virtual_network.csr_vnet.name
  name                 = "${var.csr_name}-private"
  address_prefixes     = [var.csr_private_subnet_address_space]
}


resource "azurerm_network_security_group" "public" {
  name                = "${var.csr_name}-nsg"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${data.http.ip.response_body}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "10-8"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "172-12"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/12"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "192-16"
    priority                   = 330
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "UDP500"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "UDP4500"
    priority                   = 350
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "CatchAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.csr_public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_network_interface" "csr_eth0" {
  name                = "${var.csr_name}-public-nic"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.csr_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.csr_pip.id  
  }
  enable_ip_forwarding = true
  
}

resource "azurerm_network_interface" "csr_eth1" {
  name                = "${var.csr_name}-private-nic"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.csr_private.id
    private_ip_address_allocation = "Dynamic"

  }

  enable_ip_forwarding = true
}

resource "azurerm_route_table" "public" {
  name = "${var.csr_name}-public-rtb"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name
  disable_bgp_route_propagation = true
  
  route {
    name = "10-8"
    address_prefix = "10.0.0.0/8"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }

  route {
    name = "172-12"
    address_prefix = "172.16.0.0/12"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }

  route {
    name = "192-16"
    address_prefix = "192.168.0.0/16"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }
}

resource "azurerm_route_table" "private" {
  name = "${var.csr_name}-private-rtb"
  location            = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name
  disable_bgp_route_propagation = true
  
  route {
    name = "10-8"
    address_prefix = "10.0.0.0/8"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }

  route {
    name = "172-12"
    address_prefix = "172.16.0.0/12"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }

  route {
    name = "192-16"
    address_prefix = "192.168.0.0/16"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.csr_eth1.private_ip_address
  }

  route {
    name = "Default"
    address_prefix = "0.0.0.0/0"    
    next_hop_type = "None"
  }
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.csr_public.id
  route_table_id = azurerm_route_table.public.id
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.csr_private.id
  route_table_id = azurerm_route_table.private.id
}



resource "azurerm_linux_virtual_machine" "csr" {
  name                = var.csr_name
  resource_group_name = azurerm_resource_group.csr_rg.name
  location            = azurerm_resource_group.csr_rg.location
  size                = "Standard_B2ms"
  boot_diagnostics {    
  }

  admin_username      = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false
  

  network_interface_ids = [
    azurerm_network_interface.csr_eth0.id,
    azurerm_network_interface.csr_eth1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v"
    sku       = "17_13_01a-payg-essentials"
    version   = "latest"
    # version   = "17.12.0120231025"
  }

  plan {
    name      = "17_13_01a-payg-essentials"
    product   = "cisco-c8000v"
    publisher = "cisco"
  }
  custom_data = base64encode(templatefile(local.ike_ver == "ike1" ? "${path.module}/cat8k-avtx-config.ike1" : "${path.module}/cat8k-avtx-config.ike2",
  # custom_data = base64encode(templatefile("${path.module}/cat8k-avtx.config.ike2", { 
    {
    hostname = var.csr_name
    TX_APIPA_TUN0 = split("/", local.avtxapipa1)[0]
    TX_APIPA_TUN1 = split("/", local.avtxapipa2)[0]
    CSR_APIPA_TUN0 = split("/", local.csrapipa1)[0]
    CSR_APIPA_TUN1 = split("/", local.csrapipa2)[0]
    Admin_Username = var.admin_username
    Admin_Password = var.admin_password
    TX_GW1_Public_IP = module.mc-transit.transit_gateway.public_ip
    TX_GW2_Public_IP = module.mc-transit.transit_gateway.ha_public_ip
    TX_GW1_Private_IP = module.mc-transit.transit_gateway.private_ip
    TX_GW2_Private_IP = module.mc-transit.transit_gateway.ha_private_ip
    CSR_ASN = var.csr_asn
    TX_ASN = module.mc-transit.transit_gateway.local_as_number
    PSK = var.ipsec_psk
    CSR_PIP = local.phase1_remote_identifier
    })
  )
}

/* # test vm if needed
module "azure-linux-vm-public" {
  source              = "github.com/patelavtx/azure-linux-passwd.git"
  region              = azurerm_resource_group.csr_rg.location
  resource_group_name = azurerm_resource_group.csr_rg.name
  subnet_id           = azurerm_subnet.csr_public.id
  vm_name             = "${var.csr_name}-publicvm"
  # public_key_file     = var.public_key_file
}
*/


# outputs

output "csr_public_ip" {
  value = azurerm_public_ip.csr_pip.ip_address
}

output "csr_admin_username" {
  value = var.admin_username
}

output "csr_admin_password" {
  value = var.admin_password
}

output "csr_ssh" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.csr_pip.ip_address} -oKexAlgorithms=+diffie-hellman-group14-sha1"
}

/*
output "csr_vnet_public_vm" {
  value = module.azure-linux-vm-public
}
*/