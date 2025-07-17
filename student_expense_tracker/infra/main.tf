
provider "azurerm" {
  features {}
  subscription_id = "a0973ce3-7817-4d56-b058-f11c6c32ad0d"
}

resource "azurerm_resource_group" "stucents_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "stucents-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.stucents_rg.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.stucents_rg.name
  location            = azurerm_resource_group.stucents_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.resource_group_name}-logs"
  location            = var.location
  resource_group_name = azurerm_resource_group.stucents_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${var.resource_group_name}-env"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.stucents_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_container_app" "stucents_app" {
  name                         = "stucents-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.stucents_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "stucents"
      image  = "${azurerm_container_registry.acr.login_server}/stucents-app:latest"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "MONGO_URI"
        value = var.mongo_uri
      }
    }

  }

    ingress {
      external_enabled = true
      target_port      = 3000
      transport        = "auto"
      traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.identity.id
  }
}

