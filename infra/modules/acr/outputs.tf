output "id" {
  description = "Azure Container Registry resource ID"
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}
