variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "yrci-v1"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  default     = "797a03a0-9429-4393-8662-327191141b7b"
}

variable "regions" {
  description = "Regions to deploy resources"
  type = map(object({
    name                     = string
    location                 = string
    primary                  = bool
    supports_embedding       = bool
    nearest_embedding_region = string
  }))
  default = {
    eastus2 = {
      name                     = "eastus2"
      location                 = "East US 2"
      primary                  = true
      supports_embedding       = true
      nearest_embedding_region = "eastus2"
    },
    # westus2 = {
    #   name                     = "westus"
    #   location                 = "West US"
    #   primary                  = false
    #   supports_embedding       = false
    #   nearest_embedding_region = "westus3"
    # },
    # southcentralus = {
    #   name                     = "southcentralus"
    #   location                 = "South Central US"
    #   primary                  = false
    #   supports_embedding       = false
    #   nearest_embedding_region = "eastus2"
    # },
    # northcentralus = {
    #   name                     = "northcentralus"
    #   location                 = "North Central US"
    #   primary                  = false
    #   supports_embedding       = false
    #   nearest_embedding_region = "eastus2"
    # },
    # westus3 = {
    #   name                     = "westus3"
    #   location                 = "West US 3"
    #   primary                  = false
    #   supports_embedding       = true
    #   nearest_embedding_region = "westus3"
    # }
  }
}

variable "linkedin_client_id" {
  description = "LinkedIn Client ID"
  type        = string
  sensitive   = true # Mark as sensitive to prevent it from being displayed in plain text
}

variable "linkedin_client_secret" {
  description = "LinkedIn Client Secret"
  type        = string
  sensitive   = true
  nullable    = false # Indicate that this variable is required
}

variable "linkedin_redirect_uri" {
  description = "LinkedIn Redirect URI"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "repo_branch" {
  description = "Git repository branch"
  type        = string
  default     = "main"
}

variable "allowed_cors_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["https://aon-lead-app-eastus2-1.azurewebsites.net"] # Replace with your actual frontend domain
}

variable "asp_supported_regions" {
  description = "Supported App Service regions"
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

