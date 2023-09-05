
variable "resource_name_prefix" {
  description = "Name of the prefix for all resource"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
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
