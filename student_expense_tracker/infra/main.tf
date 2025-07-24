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
  subscription_id = "8751967a-6d07-4ba9-ab04-ffc9bfdef46d"
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
  name     = "stucents-rg"
  location = "francecentral"
}

resource "azurerm_service_plan" "plan" {
  name                = "stucents-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  sku_name = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "stucents-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true

    application_stack {
      node_version = "16-lts"
    }
  }

  app_settings = {
    "MONGODB_URI" = var.mongodb_uri
  }

}

resource "azurerm_app_service_source_control" "stucentsrepo" {
  app_id   = azurerm_linux_web_app.webapp.id
  repo_url = "https://github.com/umumararungu/StuCents-app"
  branch   = "main"
}

resource "azurerm_container_registry" "acr" {
  name                = "stucentsregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "stucents-identity"
  location            = "francecentral"
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
  location                   = "francecentral"
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_container_app" "stucentsapp" {
  name                         = "stucentsapp1"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "stucents"
      image  = "stucentsregistry.azurecr.io/stucents-app:v1"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "MONGO_URI"
        value =  "MONGO_URI=mongodb://127.0.0.1:27017/expensesDB"
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

