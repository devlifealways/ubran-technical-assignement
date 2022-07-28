variable "gcp_credentials" {
  description = "Credentials file location"
  type        = string
}

variable "gcp_region" {
  description = "Regional location worldwild"
  type        = string
}

variable "gcp_project_id" {
  description = "A mean to differentiate your project from all others in Google Cloud"
  type        = string
}

variable "gcp_organization_id" {
  description = "The hierarchical super node of projects"
  type        = number
}

variable "gcp_namespace" {
  default = "urban"
  type    = string
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

variable "gcp_spot_pool_autoscaling_min_count" {
  description = "Enables autoscaling min pods behavior (required)"
  type        = number
  validation {
    condition     = var.gcp_spot_pool_autoscaling_min_count >= 0
    error_message = "Autoscaling min count should be a positive number (required)"
  }
}

variable "gcp_spot_pool_autoscaling_max_count" {
  description = "Enables autoscaling max pods behavior (required)"
  type        = number
}

variable "gcp_primary_pool_autoscaling_min_count" {
  description = "Enables autoscaling min pods behavior (required)"
  type        = number
  validation {
    condition     = var.gcp_primary_pool_autoscaling_min_count >= 0
    error_message = "Autoscaling min count should be a positive number (required)"
  }
}

variable "gcp_primary_pool_autoscaling_max_count" {
  description = "Enables autoscaling max pods behavior (required)"
  type        = number
}

variable "gcp_machine_flavor" {
  description = "Machines type to be used to form Kubernetes cluster"
  type        = string

  # https://cloud.google.com/compute/docs/general-purpose-machines
  # used this familly because I have only free-tier account
  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.gcp_machine_flavor)
    error_message = "Cluster nodes contains only e2 familly"
  }
}

variable "gcp_mtu" {
  description = "Maximum Transmission Unit in bytes"
  type        = number
  default     = 1500
  validation {
    condition     = var.gcp_mtu <= 1500 && var.gcp_mtu >= 1460
    error_message = "The minimum value for this field is 1460 and the maximum value is 1500 bytes"
  }
}

variable "gcp_enable_logging" {
  description = "Enable scrapping all of your applications logs using fluentbit agents, be aware it will cost you more (optional)"
  type        = bool
  default     = false
}

variable "gcp_enable_monitoring" {
  description = "Enable monitoring all of your applications, be aware it will cost you more (optional)"
  type        = bool
  default     = true
}

variable "gcp_node_pool_count" {
  description = "Initial cluster nodes number (optional)"
  type        = number
  default     = 1
  validation {
    condition     = var.gcp_node_pool_count >= 0
    error_message = "Cluster nodes number must be positive"
  }
}

variable "gcp_node_pool_disk_size" {
  description = "Initial cluster volumes (required)"
  type        = number
  validation {
    condition     = var.gcp_node_pool_disk_size >= 10
    error_message = "Pool volumes size must be positive and bigger or equal to 10GB"
  }
}

variable "gcp_node_locations" {
  description = "List of all zones where you want to deploy your nodes"
  type        = list(string)
  validation {
    condition     = length(var.gcp_node_locations) > 0
    error_message = "At least specify one zone"
  }
}


variable "gcp_vpc_secondary_ip_ranges" {
  description = "An array of configurations for secondary IP ranges for VM instances contained in this subnetwork"
  type = map(object({
    secondary_range = object({
      range_name    = string
      ip_cidr_range = string
    })
  }))
  default = {
    pods = {
      secondary_range = {
        range_name    = "k8s-pod-ips"
        ip_cidr_range = "10.48.0.0/14"
      }
    }
    services = {
      secondary_range = {
        range_name    = "k8s-svc-ips"
        ip_cidr_range = "10.52.0.0/20"
      }
    }
  }
}
