# Production Environment Configuration

subscription_id = "380bc159-718d-435e-93a8-03d2e7299c39"

# General settings
environment         = "prod"
location            = "centralus"
secondary_location  = "canadacentral"
resource_group_name = "three-tier-app"

# Network settings
vnet_address_space       = "10.0.0.0/16"
public_subnet_prefixes   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_prefixes  = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnet_prefixes = ["10.0.5.0/24", "10.0.6.0/24"]
bastion_subnet_prefix    = "10.0.7.0/24"
appgw_subnet_prefix      = "10.0.8.0/24"

# Compute settings
frontend_vm_size   = "Standard_D2s_v3"
backend_vm_size    = "Standard_D2s_v3"
frontend_instances = 2
backend_instances  = 2
admin_username     = "adminuser"

# Database settings
postgres_sku_name   = "GP_Standard_D2s_v3"
postgres_version    = "14"
postgres_storage_mb = 32768
postgres_db_name    = "goalsdb"
postgres_db_port    = 5432
postgres_db_sslmode = "require"
# PostgreSQL availability
enable_postgres_ha      = false
enable_postgres_replica = false
# Phase 1 - deploy base infrastructure only
deploy_compute = true

# Docker image settings

frontend_image = "frontend:latest"
backend_image  = "backend:latest"


# Tags
tags = {
  Environment = "Production"
  Project     = "Three-Tier-Application"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}

alert_email = "chauhanneru877@gmail.com"

# Azure Container Registry
acr_sku = "Standard"
