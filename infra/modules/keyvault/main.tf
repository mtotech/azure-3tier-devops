/*
 * Key Vault Module
 * Production-style Azure Key Vault using Azure RBAC.
 */

# Generate a random suffix for globally unique Key Vault name
resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "kv" {
  name                = "${var.resource_name_prefix}-kv-${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7

  # Production protection
  purge_protection_enabled = true

  # Use modern Azure RBAC instead of access policies
  enable_rbac_authorization = true

  enabled_for_disk_encryption = true

  # Keep public access enabled initially so Terraform can create secrets.
  # Later we can harden this with private endpoints / network restrictions.
  public_network_access_enabled = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Terraform / deployment identity gets permission to manage secrets.
resource "azurerm_role_assignment" "terraform_keyvault_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.object_id
}


