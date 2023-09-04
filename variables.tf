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

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}
variable "private_egress_subnets_cidr_list" {
  type        = list(any)
  description = "CIDR block list for private subnets with internet access"
  default     = []
}
variable "bastion_subnets_cidr_list" {
  type        = list(any)
  description = "CIDR block list for bastion subnets"
  default     = []
}

variable "resource_name_prefix" {
  description = "Name of the prefix for all resource"
}