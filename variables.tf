variable SysName_L {
  type        = string
  default     = "RYMOA-PORTFOLIO"
  description = "SystemNameLarge"
}
variable SysName_S {
  type        = string
  default     = "rymoa-portfolio"
  description = "SystemNameSmall"
}
variable Location {
  type        = string
  default     = "japaneast"
  description = "ResourceGroupLocation"
}
variable VNETIPaddress {
  type        = string
  default     = "10.0.0.0/16"
  description = "VnetIP"
}
variable FrSubnetIPaddress {
  type        = string
  default     = "10.0.0.0/24"
  description = "FrontendSubnetIP"
}
variable AksSubnetIPaddress {
  type        = string
  default     = "10.0.1.0/24"
  description = "AksSubnetIP"
}
variable SQLAdmin {
  type        = string
  default     = "rymoasqladmin"
  description = "SqlAdminUser"
}
variable SQLAdminPass {
  type        = string
  default     = "ZAQ!2wsxcde3"
  description = "SqlAdminPass"
}
variable AADAdminName {
  type        = string
  default     = "opadmin"
  description = "SqlAADAdminName"
}
variable TenantId {
  type        = string
  default     = "ce2cbc43-bbef-404f-9d5b-a805d131a78f"
  description = "tanantid"
}
variable ObjectId {
  type        = string
  default     = "7ced8772-bc22-439b-b0e6-b7b0a12864b9"
  description = "SqlAADAdminId"
}
variable Sql_Security_Alert {
  type        = string
  default     = "rymoa.ayadich@gmail.com"
  description = "mail"
}
variable DnsServiceIp {
  type        = string
  default     = "10.0.0.10"
  description = "AksDnsServiceIp"
}
variable ServiceCidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "AksServiceCidr"
}
variable DockerBridgeCidr {
  type        = string
  default     = "172.17.0.1/16"
  description = "AksDockerBridgeCidr"
}