locals {
  tags = {
    ManagedBy   = "Terraform"
    Environment = "production"
    App         = var.app_name
  }
}


provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = local.tags
  }
}