terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "stucentsterraform"
    container_name       = "tfstate"
    key                  = "production.terraform.tfstate"
  }
}