# Deploy a Resource Group with Azure resources.
#
# For suggested naming conventions, refer to:
#   https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

# Sample Resource Group

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.appname}-${var.environment}-main"
  location = var.location
  tags     = {
    department = var.department
  }
}

# Sample Resources

module "sqlserver1_generated_password" {
  source = "./sqlserver1_generated_password"
  appname = var.appname
  environment = var.environment
  resource_group = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
}

module "sqlserver2_assigned_password" {
  source = "./sqlserver2_assigned_password"
  appname = var.appname
  environment = var.environment
  resource_group = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sql_password = var.sql2password
}

# Add additional modules...
