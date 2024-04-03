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
