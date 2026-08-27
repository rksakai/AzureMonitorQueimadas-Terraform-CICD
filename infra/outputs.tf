output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.func.default_hostname}"
}
