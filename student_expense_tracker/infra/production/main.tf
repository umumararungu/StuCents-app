terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = "8751967a-6d07-4ba9-ab04-ffc9bfdef46d"
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
  name     = "stucents-production-rg"
  location = "francecentral"
}

resource "azurerm_container_registry" "acr" {
  name                = "stucentsregistryproduction"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "stucents-production-identity"
  location            = "francecentral"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "stucents-production-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "stucents-production-env"
  location                   = "francecentral"
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_container_app" "stucentsapp" {
  name                         = "stucents-production-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "stucents"
      image = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"


      env {
        name  = "MONGO_URI"
        value = "mongodb+srv://stuadmin:5dL9qSWYm2mqnluD@cluster0.weiu5bx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
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

  secret {
    name  = "mongo-uri"
    value = "mongodb+srv://stuadmin:5dL9qSWYm2mqnluD@cluster0.weiu5bx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
  }
}

output "container_app_url" {
  value = azurerm_container_app.stucentsapp.latest_revision_fqdn
  description = "The public URL of the deployed StuCents Container App"
}

