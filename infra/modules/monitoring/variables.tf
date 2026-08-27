variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_name_prefix" {
  type = string
}

variable "frontend_vmss_id" {
  type    = string
  default = null
}

variable "backend_vmss_id" {
  type    = string
  default = null
}

variable "create_frontend_diagnostics" {
  type    = bool
  default = false
}

variable "create_backend_diagnostics" {
  type    = bool
  default = false
}

variable "log_analytics_sku" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "alert_email" {
  type = string
}

variable "tags" {
  type = map(string)
}
