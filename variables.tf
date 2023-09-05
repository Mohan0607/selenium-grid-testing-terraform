# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

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

variable "resource_name_prefix" {
  description = "Name of the prefix for all resource"
}


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