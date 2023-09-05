
# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "sl-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "allow all traffic"
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "allow port SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 4444
    to_port     = 4444
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 5555
    to_port     = 5555
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 4442
    to_port     = 4442
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol  = "tcp"
    from_port = 4444
    to_port   = 4444
    self      = true
    #security_groups = [aws_security_group.ecs_tasks.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "sl-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "allow all traffic"
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "allow port SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    protocol        = "tcp"
    from_port       = 4444
    to_port         = 4444
    security_groups = [aws_security_group.lb.id]
  }
  ingress {
    protocol  = "tcp"
    from_port = 4444
    to_port   = 4444
    self      = true
  }
  ingress {
    protocol    = "tcp"
    from_port   = 4444
    to_port     = 4444
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 5555
    to_port     = 5555
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 5555
  #   to_port         = 5555
  #   security_groups = [aws_security_group.lb.id]
  # }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 4442
  #   to_port         = 4442
  #   security_groups = [aws_security_group.lb.id]
  # }
  # ingress {
  #   protocol        = "tcp"
  #   from_port       = 4443
  #   to_port         = 4443
  #   security_groups = [aws_security_group.lb.id]
  # }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

