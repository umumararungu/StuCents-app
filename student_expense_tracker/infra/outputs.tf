output "container_app_url" {
  value = azurerm_container_app.stucents_app.latest_revision_fqdn
}
