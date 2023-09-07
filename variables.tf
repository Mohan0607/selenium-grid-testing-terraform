variable "local_aws_profile_name" {
  type        = string
  description = "AWS Profile name used in local machine"
  default     = "default"
}

# Project Configurations and Name Conventions
variable "region" {
  type        = string
  description = "Project Region"
  default     = "us-west-1"
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "project_resource_administrator" {
  type        = string
  description = "Project Resource Administrator"
  default     = "Avinash Manjunath"
}
variable "project_name" {
  type        = string
  description = "Project name"
}


# Network Related VPC, Subnets and Security Groups
variable "vpc_id" {
  type        = string
  description = "The id of a VPC in your AWS account"
  default     = "vpc-11111111"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The ids of the public subnet, for the load balancer"
  default     = ["subnet-11111111", "subnet-2222222"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The ids of the private subnet, for the containers"
  default     = ["subnet-3333333333"]
}

#S3 Bucket 

variable "bucket_name" {
  type        = string
  description = "The name for the S3 bucket"
}

# DNS


variable "load_balancer_domain_name" {
  type        = string
  description = "Load Balancer Domain name"
}

variable "selenium_cf_aliases" {
  type        = list(string)
  description = "List of aliases used for the portal UI"
}

variable "cloufront_acm_cert_arn" {
  type        = string
  description = "ARN of the aws certificate manager used for the cloudfront"
}

variable "selenium_portal_domain_name" {
  type        = string
  description = "Domain name for the Report portal UI"
}

# ECS Fire Fox task defintions

variable "selenium_firefox_service_desired_count" {
  type        = string
  description = "Number of instances for Fire Fox Node"
}
variable "selenium_firefox_image" {
  type        = string
  description = "Image Url for Fire Fox Node image"
}
variable "selenium_firefox_task_memory" {
  type        = number
  description = "The memory allocated to the Fire Fox Node task "
}

variable "selenium_firefox_container_cpu" {
  type        = number
  description = "The CPU units allocated to the Fire Fox Node container."
}

variable "selenium_firefox_container_memory" {
  type        = number
  description = "The memory allocated to the Fire Fox Node container "
}
variable "selenium_firefox_log_configuration" {
  type        = any
  description = "The log configuration for the Fire Fox Node container."
}
variable "selenium_firefox_task_cpu" {
  type        = number
  description = "The CPU units allocated to the Fire Fox Node task."
}

# ECS Chrome task defintions


variable "selenium_chrome_service_desired_count" {
  type        = string
  description = "Number of instances for Chrome Node"
}
variable "selenium_chrome_image" {
  type        = string
  description = "Image Url for Chrome Node image"
}
variable "selenium_chrome_task_memory" {
  type        = number
  description = "The memory allocated to the Chrome Node task "
}

variable "selenium_chrome_container_cpu" {
  type        = number
  description = "The CPU units allocated to the Chrome Node container."
}

variable "selenium_chrome_container_memory" {
  type        = number
  description = "The memory allocated to the Chrome Node container "
}
variable "selenium_chrome_log_configuration" {
  type        = any
  description = "The log configuration for the Chrome Node container."
}
variable "selenium_chrome_task_cpu" {
  type        = number
  description = "The CPU units allocated to the Chrome Node task."
}

# ECS Hub task defintions


variable "selenium_hub_service_desired_count" {
  type        = string
  description = "Number of instances for hub Node"
}
variable "selenium_hub_image" {
  type        = string
  description = "Image Url for hub Node image"
}
variable "selenium_hub_task_memory" {
  type        = number
  description = "The memory allocated to the hub Node task "
}

variable "selenium_hub_container_cpu" {
  type        = number
  description = "The CPU units allocated to the hub Node container."
}

variable "selenium_hub_container_memory" {
  type        = number
  description = "The memory allocated to the hub Node container "
}
variable "selenium_hub_log_configuration" {
  type        = any
  description = "The log configuration for the hub Node container."
}
variable "selenium_hub_task_cpu" {
  type        = number
  description = "The CPU units allocated to the hub Node task."
}