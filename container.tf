#######################################################

# 01 Azure Container Registory
# 02 Azure Kubernetes Service

#######################################################

# 01 Azure Container Registory
resource "azurerm_container_registry" "default" {
    name                                = "${var.Param["SysName_L"]}ACR01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    sku                                 = "Standard"
    admin_enabled                       = false
}
# 02 Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "default" {
    name                                = "${var.Param["SysName_L"]}-AKS01"
    resource_group_name                 = azurerm_resource_group.default.name
    location                            = azurerm_resource_group.default.location
    dns_prefix                          = "${var.Param["SysName_L"]}-AKS01-dns"
    default_node_pool {
        name            = "agentpool"
        node_count      = 1
        vm_size         = "Standard_D2_v2"
        vnet_subnet_id  = azurerm_subnet.aks.id
    }
    identity {
        type                        = "UserAssigned"
        user_assigned_identity_id   = azurerm_user_assigned_identity.aks.id
    }
    network_profile {
        network_plugin      ="azure"
        dns_service_ip      = var.AKS["DnsServiceIp"]
        service_cidr        = var.AKS["serviceCidr"]
        docker_bridge_cidr  = var.AKS["dockerBridgeCidr"]
    }
    addon_profile {
        ingress_application_gateway {
        enabled         = true
        gateway_name    = "${var.Param["SysName_L"]}-AKS01-AGIC01"
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
resource "azurerm_user_assigned_identity" "aks" {
    resource_group_name = azurerm_resource_group.default.name
    location            = azurerm_resource_group.default.location
    name                = "${var.Param["SysName_L"]}-UAMI01"
}