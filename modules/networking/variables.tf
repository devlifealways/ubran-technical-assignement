variable "gcp_routing_mode" {
  description = "Is it regional or global (optional)"
  default     = "REGIONAL"
  type        = string
}

variable "gcp_region" {
  description = "Which region should be it deployed to (required)"
  type        = string
}

variable "gcp_organization_id" {
  description = "The hierarchical super node of projects (required)"
  type        = number
}

variable "gcp_mtu" {
  description = "Maximum Transmission Unit in bytes (optional)"
  type        = number
  default     = 1500
  validation {
    condition     = var.gcp_mtu <= 1500 && var.gcp_mtu >= 1460
    error_message = "The minimum value for this field is 1460 and the maximum value is 1500 bytes"
  }
}

variable "gcp_private_subnet_name" {
  description = "Private subnetwork name (optional)"
  type        = string
  default     = "private"
  validation {
    condition     = length(var.gcp_private_subnet_name) > 0
    error_message = "Subnetwork name should not be empty"
  }
}

variable "gcp_project_id" {
  description = "Google project identifier (required)"
  type        = string
}

variable "gcp_namespace" {
  description = "Prefix as an identifier (optional)"
  type        = string
  default     = "urban"
}

variable "gcp_flow_log_sampling" {
  description = "Records a sample of network flows sent from and received by VM instances (optional)"
  type        = number
  default     = 0
  validation {
    condition     = var.gcp_flow_log_sampling <= 1 && var.gcp_flow_log_sampling >= 0
    error_message = "The value of the field must be in [0, 1]"
  }
}
