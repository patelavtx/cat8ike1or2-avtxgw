# CAT8K AVTX-ikev2

- Deploys Avtx Transit + CAT8K (now that CSR is no longer available) and makes S2C connection with BGPoIPSEC

- CAT8K BYOL doesn't offer BGPoIPSEC, use PAYG  *** remember to detroy when finished ***


## Architecture
TBD
```
mc-transit <BGPoIPSEC>  CSR 
```


#
## Example of using as module.

```

module "cat8k-ikev2" {
  source = "github.com/patelavtx/cat8kikev2-avtxgw"
  account = "AZ-proj"
  cloud = "Azure"
  localasn = "65115"
  cidr = "10.115.28.0/23"
  region = "West Europe"
  tx_gwname = "aztransit115-weu
  ike_version = "ike1"        # default is ike2
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
Terraform v1.3.7
on linux_amd64
+ provider registry.terraform.io/hashicorp/azurerm v3.0.0
+ provider registry.terraform.io/hashicorp/http v3.2.1
+ provider registry.terraform.io/hashicorp/random v3.4.3
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

