output "app_service_urls" {
  description = "URLs of the deployed App Services"
  value = {
    for k, v in azurerm_linux_web_app.app : k => "https://${v.default_hostname}"
  }
}

output "app_service_names" {
  description = "Names of the App Services"
  value = {
    for k, v in azurerm_linux_web_app.app : k => v.name
  }
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.rg.name
}