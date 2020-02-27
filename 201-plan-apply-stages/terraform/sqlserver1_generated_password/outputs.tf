output "fully_qualified_domain_name" {
  value = azurerm_sql_server.example.fully_qualified_domain_name
}

output "user" {
  value = azurerm_sql_server.example.administrator_login
}

output "password" {
  value = azurerm_sql_server.example.administrator_login_password
  sensitive = true
}
