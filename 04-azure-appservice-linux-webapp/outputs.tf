# Output the default hostname of the web app
output "web_app_default_hostname" {
  description = "Default hostname of the web app"
  value       = azurerm_linux_web_app.web_app.default_hostname
}

# Output the full URL with https://
output "web_app_url" {
  description = "Full URL of the web app with HTTPS"
  value       = "https://${azurerm_linux_web_app.web_app.default_hostname}"
}

# Output the resource group name for reference
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg_app.name
}

# Output the app service plan ID
output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.plan_app.id
}

# Output the web app name
output "web_app_name" {
  description = "Name of the web app"
  value       = azurerm_linux_web_app.web_app.name
}
