# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.resource_name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Action Group for monitoring alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.resource_name_prefix}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "app-alert"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }

  tags = var.tags
}

# CPU alert - Frontend VMSS
resource "azurerm_monitor_metric_alert" "frontend_cpu" {
  count = var.create_frontend_diagnostics ? 1 : 0

  name                = "${var.resource_name_prefix}-frontend-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.frontend_vmss_id]
  description         = "Alert when frontend VMSS CPU is above 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# CPU alert - Backend VMSS
resource "azurerm_monitor_metric_alert" "backend_cpu" {
  count = var.create_backend_diagnostics ? 1 : 0

  name                = "${var.resource_name_prefix}-backend-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.backend_vmss_id]
  description         = "Alert when backend VMSS CPU is above 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}
