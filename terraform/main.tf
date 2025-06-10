terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Or a more recent version
    }
  }
}

locals {
  asp_supported_regions = {
    "eastus2" = {
      location      = "East US 2"
      instances     = 1
      openai_region = "eastus2"
    },
  }

  all_asps = flatten([
    for region, config in local.asp_supported_regions : [
      for i in range(1, config.instances + 1) : {
        name          = "aon-lead-app-eastus2-1"
        region        = region
        location      = config.location
        openai_region = config.openai_region
        custom_domain = "aon-lead-app-eastus2-1.azurewebsites.net"
      }
    ]
  ])

  primary_region = [for k, v in var.regions : v if v.primary][0]
  embedding_regions = {
    for k, v in var.regions : k => v if v.supports_embedding
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "asp" {
  for_each = var.asp_supported_regions

  name                = "aon-lead-app-${each.key}" # Use the region name as part of the name
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}

resource "azurerm_linux_web_app" "app" {
  for_each = var.asp_supported_regions

  name                = "aon-lead-app-${each.key}" # Use the region name as part of the name
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp[each.key].id

  app_settings = {
    DEBUG                   = "false"
    OTEL_SERVICE_NAME       = "aon-lead-app-${each.key}" # Use the region name as part of the name
    LINKEDIN_CLIENT_ID      = "784jsddghxw155"
    LINKEDIN_CLIENT_SECRET  = "WPL_AP1.iIRvkzWg2nzBCEyD.PsS8sg=="
    BASE_URL                = "https://aon-lead-app-eastus2-1.azurewebsites.net"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
    always_on           = true
    minimum_tls_version = "1.2"
    ftps_state          = "FtpsOnly"
    app_command_line    = "python3 -m gunicorn server:app"
    http2_enabled       = false
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }
}
