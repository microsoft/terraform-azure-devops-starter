resource "azurerm_sql_server" "example" {
  name                         = "sqldb-${var.appname}-2-${var.environment}"
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladm"
  administrator_login_password = var.sql_password
}
