#######################################################

# 01 Virtual Network (Vnet,Subnet)
# 02 Route Tables (Fr,Aks)
# 03 Network Security Group (Fr,Aks)

#######################################################




# 01 Virtual Network (Vnet,Subnet,Peering)

# Vnet
resource "azurerm_virtual_network" "default" {
    name                = "${var.Param.SysName_L}-VNET01"
    address_space       = ["${var.Param.VNET_IPaddress}"]
    resource_group_name = "${azurerm_resource_group.default.name}"
    location            = "${azurerm_resource_group.default.location}"
}

# Subnet
resource "azurerm_subnet" "fr" {
    name                        = "${azurerm_virtual_network.default.name}-SNFR01"
    address_prefixes            = "${var.Param.FrSubnetIPaddress}"
    resource_group_name         = "${azurerm_resource_group.default.name}"
    virtual_network_name        = "${azurerm_virtual_network.default.name}"
}
resource "azurerm_subnet" "aks" {
    name                        = "${azurerm_virtual_network.default.name}-SNAKS01"
    address_prefixes            = "${var.Param.AksSubnetIPaddress}"
    resource_group_name         = "${azurerm_resource_group.default.name}"
    virtual_network_name        = "${azurerm_virtual_network.default.name}"
    service_endpoints           = ["Microsoft.Sql"]
}

# 02 RouteTables

# Fr
resource "azurerm_route_table" "fr" {
    name                            = "${azurerm_subnet.fr.name}-RT01"
    resource_group_name             = "${azurerm_resource_group.default.name}"
    location                        = "${azurerm_resource_group.default.location}"
    disable_bgp_route_propagation   = false
    route {
        name                    = "Internet"
        address_prefix          = "0.0.0.0/0"
        next_hop_type           = "Internet"
    }
}
# Aks
resource "azurerm_route_table" "aks" {
    name                            = "${azurerm_subnet.aks.name}-RT01"
    resource_group_name             = "${azurerm_resource_group.default.name}"
    location                        = "${azurerm_resource_group.default.location}"
    disable_bgp_route_propagation   = false
    route {
        name                    = "Internet"
        address_prefix          = "0.0.0.0/0"
        next_hop_type           = "Internet"
    }
}

# Route Table Associations
resource "azurerm_subnet_route_table_association" "fr" {
    subnet_id       = "${azurerm_subnet.fr.id}"
    route_table_id  = "${azurerm_route_table.fr.id}"
}
resource "azurerm_subnet_route_table_association" "aks" {
    subnet_id       = "${azurerm_subnet.aks.id}"
    route_table_id  = "${azurerm_route_table.aks.id}"
}


#Fr Subnet
resource "azurerm_network_security_group" "fr" {
    name                = "${azurerm_subnet.fr.name}-NSG01"
    resource_group_name = "${azurerm_resource_group.default.name}"
    location            = "${azurerm_resource_group.default.location}"

    #InBound Rules
    security_rule {
        priority                        = 100
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound0100"
        description                     = "バックエンドの正常性 API が機能するために必要(ApplicationGateway)"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "*"
        destination_port_range          = "65503-65534"
        destination_address_prefix      = "${var.Param.FrSubnetIPaddress}"
    }
    security_rule {
        priority                        = 110
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound0110"
        description                     = "Azure Load Balancerからの通信"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "AzureLoadBalancer"
        destination_port_range          = "*"
        destination_address_prefix      = "${var.Param.FrSubnetIPaddress}"
    }
    security_rule {
        priority                        = 120
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound0120"
        description                     = "同一サブネット間の通信を許可"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "${var.Param.FrSubnetIPaddress}"
        destination_port_range          = "*"
        destination_address_prefix      = "${var.Param.FrSubnetIPaddress}"
    }
    security_rule {
        priority                        = 130
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound0130"
        description                     = "Application Gateway（WAF）経由の通信"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "TCP"
        source_port_range               = "*"
        source_address_prefix           = "Internet"
        destination_port_range          = "443"
        destination_address_prefix      = "*"
    }
    security_rule {
        priority                        = 4096
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound4096"
        description                     = "Deny All InBound"
        direction                       = "Inbound"
        access                          = "Deny"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "*"
        destination_port_range          = "*"
        destination_address_prefix      = "*"
    }
}
#Aks Subnet
resource "azurerm_network_security_group" "aks" {
    name                = "${azurerm_subnet.aks.name}-NSG01"
    resource_group_name = "${azurerm_resource_group.default.name}"
    location            = "${azurerm_resource_group.default.location}"
    #InBound Rules
    security_rule {
        priority                        = 100
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound0100"
        description                     = "FRサブネットからの通信"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "${var.Param.FrSubnetIPaddress}"
        destination_port_range          = "*"
        destination_address_prefix      = "${var.Param.AksSubnetIPaddress}"
    }
    security_rule {
        priority                        = 110
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound0110"
        description                     = "Azure Load Balancerからの通信"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "AzureLoadBalancer"
        destination_port_range          = "*"
        destination_address_prefix      = "${var.Param.AksSubnetIPaddress}"
    }
    security_rule {
        priority                        = 120
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound0120"
        description                     = "同一サブネット間の通信を許可"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "${var.Param.AksSubnetIPaddress}"
        destination_port_range          = "*"
        destination_address_prefix      = "${var.Param.AksSubnetIPaddress}"
    }
    security_rule {
        priority                        = 4096
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound4096"
        description                     = "Deny All InBound"
        direction                       = "Inbound"
        access                          = "Deny"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = "*"
        destination_port_range          = "*"
        destination_address_prefix      = "*"
    }
}


#NSG Associations
resource "azurerm_subnet_network_security_group_association" "fr" {
    subnet_id                   = "${azurerm_subnet.fr.id}"
    network_security_group_id   = "${azurerm_network_security_group.fr.id}"
}
resource "azurerm_subnet_network_security_group_association" "aks" {
    subnet_id                   = "${azurerm_subnet.aks.id}"
    network_security_group_id   = "${azurerm_network_security_group.aks.id}"
}







