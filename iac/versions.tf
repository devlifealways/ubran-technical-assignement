terraform {
  required_version = ">= 1.2.3"
  required_providers {
    aws = {
      source  = "hashicorp/google"
      version = "~> 4.29.0"
    }
  }
}
