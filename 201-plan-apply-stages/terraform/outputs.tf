output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "sqlserver1_host" {
  value = module.sqlserver1_generated_password.fully_qualified_domain_name
}

output "sqlserver1_user" {
  value = module.sqlserver1_generated_password.user
}

output "sqlserver1_password" {
  value = module.sqlserver1_generated_password.password
  sensitive = true
}
