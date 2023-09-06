
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

#  ECS task definitions details
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "selenium/hub:3.141.59"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 4444
}

# variable "app_count" {
#   description = "Number of docker containers to run"
#   default     = 3
# }

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

# S3 Bucket 

# variable "bucket_prefix" {
#   type        = string
#   description = "The prefix for the S3 bucket"
#   default     = "tf-s3-website"
# }
# variable "domain_name" {
#   type        = string
#   description = "The domain name to use"
#   default     = "demo.hands-on-cloud.com"
# }