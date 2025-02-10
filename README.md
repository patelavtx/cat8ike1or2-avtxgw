# CAT8ike1or2-avtxgw


- Deploys Avtx Transit + CAT8K (now that CSR is no longer available) and makes S2C connection with BGPoIPSEC

- CAT8K BYOL doesn't offer BGPoIPSEC, use PAYG  *** remember to detroy when finished ***


## Architecture
TBD
```
mc-transit (aztransit115-weu; asn=localasn=<toset>; cidr=<toset>, ) 
<BGPoIPSEC>
CSR (asn=65015 ; 10.15.32.0/24; weu)
```


#
## Example of using as module.

```

module "cat8k-ikev2" {
  source = "github.com/patelavtx/cat8kikev2-avtxgw"
  account = "AZ-proj"
  cloud = "Azure"
  localasn = "65115"              # set transit gw asn
  cidr = "10.115.28.0/23"         # set transit gw cidr
  region = "West Europe"          # default value
  tx_gwname = "aztransit115-weu   # default value
  ike_version = "ike1"            # default is ike2
}

```


## VARIABLES



Suggested variables to set.  Most mc-transit variables for transit gateway can be set.

| Key            | Default       | Description               |
| ------------- |:-------------:| --------------------------:|
| csr_rg_name    | atulrg-csrike2 |  optional         |
| csr_rg_location| West Europe    |  optional          |
| csr_name       | csr-ike1      |  optional          |
| csr_vnet_address_space | 10.204.32.0/24 | optionsal |
| csr_public_subnet_address_space | 10.204.32.0/25 | optional |
| csr_private_subnet_address_space | 10.244.32.128/2 | optional |
| csr_asn      | 65204 | optional |
| admin_username | admin  | opt |
| admin_password | Aviatrix123#  | opt |
| ipsec_psk | Aviatrix123# | opt |
| account |    |  mandatory |
| cloud |     |  set to Azure module only for Azure deployment |
| cidr |      |  mandatory ;  set transit gw vne cidr |
| region | West Europe |  optional  |
| localasn |        |  mandatory - set value |
| 






## Validated environment
```
Module version	Terraform version	Controller version	Terraform provider version
v2.5.4	        >= 1.3.0	        >= 7.1	            ~>3.1.0
```

## providers.tf
```
terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
      version = "~> 3.1.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      #version = ">= 3.15.0"
    }
  }
}


# Configure Aviatrix and Azure provider
provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password

}

provider "azurerm" {
    features {}
}
```

