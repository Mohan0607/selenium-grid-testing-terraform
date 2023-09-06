locals {
  profile = var.local_aws_profile_name
  default_tags = {
    #Environment   = title(var.project_environment)
    CreatedBy     = "Terraform"
    Terraform     = "True"
    Department    = "Engineering"
    Administrator = title(var.project_resource_administrator)
    Project       = title(var.project_name)
  }
}

# Specify the provider and access details
provider "aws" {
  profile = "default"
  region  = var.region
  default_tags {
    tags = local.default_tags
  }
}