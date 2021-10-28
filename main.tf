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

#######################################################

# 01 Virtual Network (Vnet,Subnet)
# 02 Route Tables (Fr,Aks)
# 03 Network Security Group (Fr,Aks)

#######################################################

# 01 Virtual Network (Vnet,Subnet,Peering)

# Vnet
resource "azurerm_virtual_network" "default" {
    name                = "${var.SysName_L}-VNET01"
    address_space       = [var.VNETIPaddress]
    resource_group_name = azurerm_resource_group.default.name
    location            = azurerm_resource_group.default.location
}

# Subnet
resource "azurerm_subnet" "fr" {
    name                        = "${azurerm_virtual_network.default.name}-SNFR01"
    address_prefixes            = [var.FrSubnetIPaddress]
    resource_group_name         = azurerm_resource_group.default.name
    virtual_network_name        = azurerm_virtual_network.default.name
}
resource "azurerm_subnet" "aks" {
    name                        = "${azurerm_virtual_network.default.name}-SNAKS01"
    address_prefixes            = [var.AksSubnetIPaddress]
    resource_group_name         = azurerm_resource_group.default.name
    virtual_network_name        = azurerm_virtual_network.default.name
    service_endpoints           = ["Microsoft.Sql"]
}

# 02 RouteTables

# Fr
resource "azurerm_route_table" "fr" {
    name                            = "${azurerm_subnet.fr.name}-RT01"
    resource_group_name             = azurerm_resource_group.default.name
    location                        = azurerm_resource_group.default.location
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
    resource_group_name             = azurerm_resource_group.default.name
    location                        = azurerm_resource_group.default.location
    disable_bgp_route_propagation   = false
    route {
        name                    = "Internet"
        address_prefix          = "0.0.0.0/0"
        next_hop_type           = "Internet"
    }
}

# Route Table Associations
resource "azurerm_subnet_route_table_association" "fr" {
    subnet_id       = azurerm_subnet.fr.id
    route_table_id  = azurerm_route_table.fr.id
}
resource "azurerm_subnet_route_table_association" "aks" {
    subnet_id       = azurerm_subnet.aks.id
    route_table_id  = azurerm_route_table.aks.id
}


#Fr Subnet
resource "azurerm_network_security_group" "fr" {
    name                = "${azurerm_subnet.fr.name}-NSG01"
    resource_group_name = azurerm_resource_group.default.name
    location            = azurerm_resource_group.default.location

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
        destination_port_range          = "65200-65535"
        destination_address_prefix      = var.FrSubnetIPaddress
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
        destination_address_prefix      = var.FrSubnetIPaddress
    }
    security_rule {
        priority                        = 120
        name                            = "${azurerm_subnet.fr.name}-NSG01-inbound0120"
        description                     = "同一サブネット間の通信を許可"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = var.FrSubnetIPaddress
        destination_port_range          = "*"
        destination_address_prefix      = var.FrSubnetIPaddress
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
    resource_group_name = azurerm_resource_group.default.name
    location            = azurerm_resource_group.default.location
    #InBound Rules
    security_rule {
        priority                        = 100
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound0100"
        description                     = "FRサブネットからの通信"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = var.FrSubnetIPaddress
        destination_port_range          = "*"
        destination_address_prefix      = var.AksSubnetIPaddress
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
        destination_address_prefix      = var.AksSubnetIPaddress
    }
    security_rule {
        priority                        = 120
        name                            = "${azurerm_subnet.aks.name}-NSG01-inbound0120"
        description                     = "同一サブネット間の通信を許可"
        direction                       = "Inbound"
        access                          = "Allow"
        protocol                        = "*"
        source_port_range               = "*"
        source_address_prefix           = var.AksSubnetIPaddress
        destination_port_range          = "*"
        destination_address_prefix      = var.AksSubnetIPaddress
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
    subnet_id                   = azurerm_subnet.fr.id
    network_security_group_id   = azurerm_network_security_group.fr.id
}
resource "azurerm_subnet_network_security_group_association" "aks" {
    subnet_id                   = azurerm_subnet.aks.id
    network_security_group_id   = azurerm_network_security_group.aks.id
}

#######################################################

# 01 Azure SQL Server
# 02 Azure SQL Database

#######################################################

# 01 Azure SQL Server
resource "azurerm_sql_server" "default" {
    name                                = "${var.SysName_S}-sqs01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    version                             = "12.0"
    administrator_login                 = var.SQLAdmin
    administrator_login_password        = var.SQLAdminPass
}
# Server Administrators
resource "azurerm_sql_active_directory_administrator" "dafault" {
    server_name         = azurerm_sql_server.default.name
    resource_group_name = azurerm_resource_group.default.name
    login               = var.AADAdminName
    tenant_id           = var.TenantId
    object_id           = var.ObjectId
}
#Server Firewall Rules
resource "azurerm_sql_firewall_rule" "default" {
    name                = "AllowAllWindowsAzureIps"
    server_name         = azurerm_sql_server.default.name
    resource_group_name = azurerm_resource_group.default.name
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}
#Server Virtual Network Rules
resource "azurerm_sql_virtual_network_rule" "default" {
    name                = "${var.SysName_S}-sqs01-VNRule01"
    server_name         = azurerm_sql_server.default.name
    resource_group_name = azurerm_resource_group.default.name
    subnet_id           = azurerm_subnet.aks.id
}
#Server Security Alert Policy
resource "azurerm_mssql_server_security_alert_policy" "default" {
    server_name         = azurerm_sql_server.default.name
    resource_group_name = azurerm_resource_group.default.name
    state               = "Enabled"
    retention_days      = 0
    email_addresses     = [var.Sql_Security_Alert]
}

# 02 Azure SQL Database
resource "azurerm_sql_database" "default" {
    name                                = "${var.SysName_L}-SQD01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    server_name                         = azurerm_sql_server.default.name
    edition                             = "Basic"
}

#######################################################

# 01 Azure Container Registory
# 02 Azure Kubernetes Service

#######################################################

# 01 Azure Container Registory
resource "azurerm_container_registry" "default" {
    name                                = "${var.SysName_L}ACR01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    sku                                 = "Standard"
    admin_enabled                       = false
}
# 02 Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "default" {
    name                                = "${var.SysName_L}-AKS01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    dns_prefix                          = "${var.SysName_L}-AKS01-dns"
    default_node_pool {
        name            = "agentpool"
        node_count      = 1
        vm_size         = "Standard_D2_v2"
        vnet_subnet_id  = azurerm_subnet.aks.id
    }
    identity {
        type                        = "SystemAssigned"
    }
    network_profile {
        network_plugin      ="azure"
        dns_service_ip      = var.DnsServiceIp
        service_cidr        = var.ServiceCidr
        docker_bridge_cidr  = var.DockerBridgeCidr
    }
    addon_profile {
        ingress_application_gateway {
        enabled         = true
        gateway_name    = "${var.SysName_L}-AKS01-AGIC01"
        subnet_id       = azurerm_subnet.fr.id
        }
    }
    role_based_access_control {
        enabled = true
    }
}

#NodePool
resource "azurerm_kubernetes_cluster_node_pool" "default" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Linux"
}
#AKS ACR Integration
resource "azurerm_role_assignment" "aks_managedid_container_registry" {
  scope                = azurerm_container_registry.default.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
}