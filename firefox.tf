
resource "aws_ecs_service" "selenium_firefox" {
  name            = join("-", [var.resource_name_prefix, "firefoxnode"])
  cluster         = aws_ecs_cluster.selenium_grid.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.selenium_firefox.arn
  service_registries {
    registry_arn   = aws_service_discovery_service.hub.arn
    container_name = "selenium-firefox-container"
  }
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private_egress[*].id
  }
}
resource "aws_ecs_task_definition" "selenium_firefox" {
  family                   = join("-", [var.resource_name_prefix, "firefoxnode", "task"])
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  container_definitions    = <<DEFINITION
[
   {
            "name": "selenium-firefox-container", 
            "image": "selenium/node-firefox:4.11.0", 
            "portMappings": [
                {
                    "hostPort": 5555,
                    "protocol": "tcp",
                    "containerPort": 5555
                }
            ],
            "essential": true, 
            "entryPoint": [], 
            "command": [ "/bin/bash", "-c", "PRIVATE=$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[1].Networks[0].IPv4Addresses[0]') ; export REMOTE_HOST=\"http://$PRIVATE:5555\" ; /opt/bin/entry_point.sh" ],
            "environment": [
                {
                  "name": "SE_EVENT_BUS_HOST",
                  "value": "hub.selenium"
                },
                {
                  "name": "HUB_PORT",
                  "value": "4444"
                },
                {
                  "name": "SE_EVENT_BUS_PUBLISH_PORT",
                  "value": "4442"
                },
                {
                  "name": "SE_EVENT_BUS_SUBSCRIBE_PORT",
                  "value": "4443"
                },
                {
                    "name": "NODE_MAX_SESSION",
                    "value": "3"
                },
                {
                    "name": "NODE_MAX_INSTANCES",
                    "value": "3"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group":"true",
                    "awslogs-group": "selenium-chrome-log-group",
                    "awslogs-region": "eu-west-1",
                    "awslogs-stream-prefix": "firefox"
                }
            }
        }
]
DEFINITION
}
