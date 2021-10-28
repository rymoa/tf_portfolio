terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.82.0"
    }
  }
}
  provider "azurerm" {
  features {}
}

#Resource Group
resource "azurerm_resource_group" "default" {
    name        = "${var.SysName_L}-RG01"
    location    = var.Location
    tags        = {}
}