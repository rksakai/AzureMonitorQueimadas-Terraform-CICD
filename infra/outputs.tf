output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.func.default_hostname}"
}
