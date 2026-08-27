variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for VMSS instances"
  type        = string
}

variable "appgw_subnet_id" {
  description = "ID of the subnet for Application Gateway (frontend only)"
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for VMSS administrative access"
  type        = string
}



variable "docker_image" {
  description = "Full Docker image name (e.g. 'username/image:tag')"
  type        = string
}

variable "is_frontend" {
  description = "Whether this is the frontend tier (true) or backend tier (false)"
  type        = bool
}

variable "application_port" {
  description = "Port that the application listens on"
  type        = number
}

variable "health_probe_path" {
  description = "Path for health probe"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "database_connection" {
  description = "Database connection details (for backend only)"
  type = object({
    host     = string
    port     = number
    username = string
    password = string
    dbname   = string
    sslmode  = string
  })
  default   = null
  sensitive = true
}

variable "backend_load_balancer_ip" {
  description = "Private IP address of the backend load balancer (for frontend only)"
  type        = string
  default     = null
}

variable "acr_id" {
  description = "Azure Container Registry resource ID"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "acr_login_server" {
  description = "Azure Container Registry login server"
  type        = string
}
