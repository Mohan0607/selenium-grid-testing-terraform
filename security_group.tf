locals {
  selenium_lb_sg_name  = join("-", [var.resource_name_prefix, "lb", "sg"])
  selenium_ecs_sg_name = join("-", [var.resource_name_prefix, "ecs", "sg"])

}

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = local.selenium_lb_sg_name
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.selenium_lb_sg_name
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = local.selenium_ecs_sg_name
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id
  ingress {
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "allow all traffic"
    from_port   = 4442
    protocol    = "tcp"
    to_port     = 5555
  }
  ingress {
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "allow port SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    protocol        = "tcp"
    from_port       = 4442
    to_port         = 5555
    security_groups = [aws_security_group.lb.id]
  }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 5555
  #   to_port         = 5555
  #   security_groups = [aws_security_group.lb.id]
  # }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 4443
  #   to_port         = 4443
  #   security_groups = [aws_security_group.lb.id]
  # }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 4442
  #   to_port         = 4442
  #   security_groups = [aws_security_group.lb.id]
  # }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.selenium_ecs_sg_name
  }
}