resource "azurerm_container_registry" "main" {
  name                = "${replace(var.resource_name_prefix, "-", "")}acr${random_string.acr_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = var.acr_sku
  admin_enabled = false

  public_network_access_enabled = true

  tags = var.tags
}

resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}
