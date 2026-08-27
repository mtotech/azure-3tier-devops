variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix used for Azure resource names"
  type        = string
}

variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags applied to ACR"
  type        = map(string)
}
