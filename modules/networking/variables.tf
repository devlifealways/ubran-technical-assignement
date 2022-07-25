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
