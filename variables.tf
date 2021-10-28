###########
#Variables#
###########


#Secret
variable "Secret" {
  default = {
    "subscription_id" = ""
    "tenant_id"       = ""
    "client_id"       = ""
    "client_secret"   = ""
    "SQLAdmin"      = ""
    "SQLAdminPass"      = ""
  }
}


#System Resource Variables
variable "Param" {
  default = {
    "SysName_L"         = "RYMOA-PORTFOLIO"
    "SysName_S"         = "rymoa-portfolio"
    "Location"          = "japaneast"
    "VNET_IPaddress"    = "10.0.0.0/16"
    "FrSubnetIPaddress" = "10.0.0.0/24"
    "AksSubnetIPaddress" = "10.0.1.0/24"
  }

}

# #SQL Server Configuration
# variable "SQL" {
#   default = {
#     "AdminName_AAD" = ""
#     "ObjectId"      = ""
#   }
# }

# #Alert Configuration
# variable "Alert" {
#   default = {
#     "Sql_Security_Alert" = [
#       ""
#     ]
#   }

# }

#Azure Kubernetes Service Configuration
variable "AKS" {
  default = {
    "DnsServiceIp" = "10.0.0.10"
    "serviceCidr"      = "10.0.0.0/16"
    "dockerBridgeCidr" = "172.17.0.1/16"
  }
}





