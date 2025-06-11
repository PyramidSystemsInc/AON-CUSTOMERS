variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "797a03a0-9429-4393-8662-327191141b7b"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "yrci-v1"
}

variable "asp_supported_regions" {
  description = "Map of supported regions for App Service Plans"
  type = map(object({
    location      = string
    instances     = number
    openai_region = string
  }))
  default = {
    "eastus2" = {
      location      = "East US 2"
      instances     = 1
      openai_region = "eastus2"
    }
  }
}

variable "regions" {
  description = "Map of regions configuration"
  type = map(object({
    location            = string
    primary             = bool
    supports_embedding = bool
    openai_region       = string
  }))
  default = {
    "eastus2" = {
      location            = "East US 2"
      primary             = true
      supports_embedding = true
      openai_region       = "eastus2"
    },
    "westus2" = {
      location            = "West US 2"
      primary             = false
      supports_embedding = false
      openai_region       = "eastus2"
    }
  }
}