#Azure SQL Server
resource "azurerm_sql_server" "default" {
    name                                = "${lookup(var.Param, "SysName_S")}-sqs01"
    resource_group_name                 = "${azurerm_resource_group.default.name}"
    location                            = "${azurerm_resource_group.default.location}"
    version                             = "12.0"
    administrator_login                 = "${lookup(var.Secret, "SQLAdmin")}"
    administrator_login_password        = "${lookup(var.Secret, "SQLAdminPass")}"
}
# Server Administrators
resource "azurerm_sql_active_directory_administrator" "dafault" {
    server_name         = "${azurerm_sql_server.default.name}"
    resource_group_name = "${azurerm_resource_group.default.name}"
    tenant_id           = "${lookup(var.Secret, "tenant_id")}"
    login               = "${lookup(var.SQL, "AdminName_AAD")}"
    object_id           = "${lookup(var.SQL, "ObjectId")}"
}
#Server Firewall Rules
resource "azurerm_sql_firewall_rule" "default" {
    name                = "AllowAllWindowsAzureIps"
    server_name         = "${azurerm_sql_server.default.name}"
    resource_group_name = "${azurerm_resource_group.default.name}"
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}
#Server Virtual Network Rules
resource "azurerm_sql_virtual_network_rule" "default" {
    name                = "${lookup(var.Param, "SysName_S")}-sqs01-VNRule01"
    server_name         = "${azurerm_sql_server.default.name}"
    resource_group_name = "${azurerm_resource_group.default.name}"
    subnet_id           = "${azurerm_subnet.aks.id}"
}
#Server Security Alert Policy
resource "azurerm_mssql_server_security_alert_policy" "default" {
    server_name         = "${azurerm_sql_server.default.name}"
    resource_group_name = "${azurerm_resource_group.default.name}"
    state               = "Enabled"
    retention_days      = 0
    email_addresses     = "${lookup(var.Alert, "Sql_Security_Alert")}"
}

#Azure SQL Database
resource "azurerm_sql_database" "default" {
    name                                = "${lookup(var.Param, "SysName_L")}-SQD01"
    resource_group_name                 = "${azurerm_resource_group.default.name}"
    location                            = "${azurerm_resource_group.default.location}"
    server_name                         = "${azurerm_sql_server.default.name}"
    edition                             = "Basic"
    max_size_bytes                      = "268435456000"
}