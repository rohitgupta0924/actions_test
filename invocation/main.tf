terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
  }
  resource_provider_registrations = "core"
}
resource "azurerm_resource_group" "githubactiontest" {
  name     = "githubactiontest-resources"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "githubactiontest" {
  name                = "githubactiontest-appserviceplan"
  location            = azurerm_resource_group.githubactiontest.location
  resource_group_name = azurerm_resource_group.githubactiontest.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_windows_web_app" "githubactiontest_windows" {
  name                = "githubactiontest-windows-webapp"
  location            = azurerm_resource_group.githubactiontest.location
  resource_group_name = azurerm_resource_group.githubactiontest.name
  service_plan_id = azurerm_app_service_plan.githubactiontest.id

  site_config {
    application_stack {
      dotnet_version = "v4.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

resource "azurerm_linux_web_app" "githubactiontest_linux" {
  name                = "githubactiontest-linux-webapp"
  location            = azurerm_resource_group.githubactiontest.location
  resource_group_name = azurerm_resource_group.githubactiontest.name
  service_plan_id = azurerm_app_service_plan.githubactiontest.id

  site_config {
    linux_fx_version = "PYTHON|3.8"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

resource "azurerm_storage_account" "githubactiontest" {
  name                     = "githubactionteststorageacct_99077"
  resource_group_name      = azurerm_resource_group.githubactiontest.name
  location                 = azurerm_resource_group.githubactiontest.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "githubactiontest" {
  name                  = "content"
  storage_account_id  = azurerm_storage_account.githubactiontest.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "githubactiontest_windows" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.githubactiontest.name
  storage_container_name = azurerm_storage_container.githubactiontest.name
  type                   = "Block"
  source                 = "windows_index.html"
}

resource "azurerm_storage_blob" "githubactiontest_linux" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.githubactiontest.name
  storage_container_name = azurerm_storage_container.githubactiontest.name
  type                   = "Block"
  source                 = "linux_index.html"
}
