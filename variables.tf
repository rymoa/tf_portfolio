variable SysName_L {
  type        = string
  default     = "RymoaPortfolio"
  description = "SystemNameLarge"
}
variable SysName_S {
  type        = string
  default     = "rymoaportfolio"
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
variable SQLAdminPass {}
variable AADAdminName {}
variable TenantId {}
variable ObjectId {}
variable Sql_Security_Alert {}