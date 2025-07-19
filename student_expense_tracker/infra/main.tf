
provider "azurerm" {
  features {}
  subscription_id = "a0973ce3-7817-4d56-b058-f11c6c32ad0d"
}

resource "azurerm_resource_group" "rg" {
  name     = "stucents-resouce-group"
  location = "eastus"
}

resource "azurerm_container_registry" "acr" {
  name                = "stucents-registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "stucents-identity"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}



resource "azurerm_log_analytics_workspace" "logs" {
  name                = "azure-log1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "stucents-env"
  location                   = "eastus"
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_container_app" "stucents_app" {
  name                         = "stucents-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "stucents"
      image  = "${azurerm_container_registry.acr.login_server}/stucents-app:v1"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "MONGO_URI"
        value =  "MONGO_URI=mongodb://127.0.0.1:27017/expensesDB"
      }
    }

    # scale = {
    #   minreplicas = 1
    #   maxreplicas = 1
    # }

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

