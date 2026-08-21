terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatequeimadas"
    container_name       = "tfstate"
    key                  = "monitor-queimadas.tfstate"
  }
}

provider "azurerm" {
  features {}
}
