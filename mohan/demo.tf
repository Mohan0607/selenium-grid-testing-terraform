# Define the provider
provider "aws" {
  region = "us-east-1" # Set your desired AWS region
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
# Create a VPC or use an existing one

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_hostnames = true
  # tags = {
  #   Name = local.vpc_name
  # }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  # tags = {
  #   Name = local.igw_name
  # }
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.bastion[0].id

  depends_on = [aws_internet_gateway.main]

  # tags = {
  #   Name = local.nat_gw_name
  # }

}


resource "aws_eip" "nat_gw" {
  vpc = true
}
# Bastion Subnet
resource "aws_subnet" "bastion" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  count             = length(var.bastion_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.bastion_subnets_cidr_list[count.index]

  # tags = {
  #   Name = join("-", [var.resource_name_prefix, "bastion", data.aws_availability_zones.available.names[count.index]])
  # }
}


resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.main.id

  # tags = {
  #   Name = local.bastion_rtb_name
  # }
}

resource "aws_route" "bastion_internet" {
  route_table_id         = aws_route_table.bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "bastion" {
  count          = length(aws_subnet.bastion[*].id)
  subnet_id      = aws_subnet.bastion[count.index].id
  route_table_id = aws_route_table.bastion.id
}

# Private with Internet access
resource "aws_subnet" "private_egress" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  count             = length(var.private_egress_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_egress_subnets_cidr_list[count.index]

  # tags = {
  #   Name = join("-", [var.resource_name_prefix, "private-egress", data.aws_availability_zones.available.names[count.index]])
  # }
}


resource "aws_route_table" "private_egress" {
  vpc_id = aws_vpc.main.id

  # tags = {
  #   Name = local.private_egress_rtb_name
  # }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_egress.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_egress" {
  count     = length(aws_subnet.private_egress[*].id)
  subnet_id = aws_subnet.private_egress[count.index].id

  route_table_id = aws_route_table.private_egress.id
}


# Create a security group for the ALB
resource "aws_security_group" "alb_security_group" {
  name_prefix = "dentalxchange-selenium-alb-sg"
  vpc_id      = aws_vpc.main.id

  # Ingress rule for port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "node_security_group" {
  name_prefix = "dentalxchange-selenium-alb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 4444
    to_port         = 4444
    security_groups = [aws_security_group.alb_security_group.id]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 5555
    to_port         = 5555
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create an Application Load Balancer (ALB)
resource "aws_lb" "selenium_alb" {
  name               = "dentalx-selenium-grid-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.private_egress[*].id
  security_groups    = [aws_security_group.alb_security_group.id]
}

# Create ECS cluster
resource "aws_ecs_cluster" "selenium_cluster" {
  name = "dentalx-selenium-grid-cluster"
}

# Create an IAM role for ECS
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com",
      },
    }],
  })
}

# Attach the execution role policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Define your ECS task definition and service for the hub
resource "aws_ecs_task_definition" "hub_task" {
  family                   = "dentalx-selenium-hub"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  cpu    = "1024"
    memory = "2048"
  container_definitions = jsonencode([{
    name   = "selenium-hub-container"
    image  = "selenium/hub:4.11.0"
  
    portMappings = [{
      containerPort = 4444
      hostPort      = 4444
    }]
    environment = [
      {
        name  = "SE_OPTS"
        value = "--log-level FINE"
      }
    ]
  }])
}

resource "aws_ecs_service" "hub_service" {
  name            = "dentalx-se-hub-service"
  cluster         = aws_ecs_cluster.selenium_cluster.id
  task_definition = aws_ecs_task_definition.hub_task.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.private_egress[*].id
    security_groups = [aws_security_group.node_security_group.id]
  }
  depends_on = [aws_lb_listener.hub_listener]
}

# Define your ECS task definition and service for Chrome nodes
resource "aws_ecs_task_definition" "chrome_task" {
  family                   = "dentalx-selenium-chrome"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  cpu                      = "1024"
  memory                   = "2048"
  container_definitions = jsonencode([{
    name  = "selenium-chrome-container"
    image = "selenium/node-chrome:4.11.0"
    portMappings = [{
      containerPort = 5555
      hostPort      = 5555
    }]
    environment = [
      {
        name  = "SE_EVENT_BUS_HOST"
        value = "dentalx-se-hub-service"
      },
      {
        name  = "SE_EVENT_BUS_PUBLISH_PORT"
        value = "4442"
      },
      {
        name  = "SE_EVENT_BUS_SUBSCRIBE_PORT"
        value = "4443"
      },
      {
        name  = "NODE_MAX_INSTANCES"
        value = "5"
      },
      {
        name  = "NODE_MAX_SESSION"
        value = "5"
      },
      {
        name  = "SE_OPTS"
        value = "--log-level FINE"
      }
    ]
  }])
}

resource "aws_ecs_service" "chrome_service" {
  name            = "dentalx-se-chrome-node-service"
  cluster         = aws_ecs_cluster.selenium_cluster.id
  task_definition = aws_ecs_task_definition.chrome_task.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = aws_subnet.private_egress[*].id
    security_groups = [aws_security_group.node_security_group.id]
  }
  depends_on = [aws_lb_listener.chrome_listener]
}

# Create an ALB listener for the hub service
resource "aws_lb_listener" "hub_listener" {
  load_balancer_arn = aws_lb.selenium_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

# Create an ALB listener for the Chrome node service (similar to hub_listener)
resource "aws_lb_listener" "chrome_listener" {
  load_balancer_arn = aws_lb.selenium_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}


# Output the load balancer DNS name
output "LoadBalancerDNS" {
  value = aws_lb.selenium_alb.dns_name
}
