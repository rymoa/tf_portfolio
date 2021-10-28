terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

#Resource Group
resource "azurerm_resource_group" "default" {
    name        = "${lookup(var.Param, "SysName_L")}-RG01"
    location    = "${lookup(var.Param, "Location")}"
    tags        = {}
}