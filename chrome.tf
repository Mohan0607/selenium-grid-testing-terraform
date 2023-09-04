
resource "aws_ecs_service" "selenium_chrome" {
  name            = join("-", [var.resource_name_prefix, "chromenode"])
  cluster         = aws_ecs_cluster.selenium_grid.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.selenium_chrome.arn
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private_egress[*].id
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.hub.arn
    container_name = "selenium-chrome-container"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]

}

resource "aws_ecs_task_definition" "selenium_chrome" {
  family             = join("-", [var.resource_name_prefix, "chromenode", "task"])
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = "1024"
  memory = "2048"

  container_definitions = jsonencode([{
    name  = "selenium-chrome-container"
    image = "selenium/node-chrome:4.11.0"
    portMappings = [{
      containerPort = 5555
      hostPort      = 5555
    }]
    environment = [
      {
        name  = "SE_OPTS"
        value = "--host selenium-hub-container --port 4444"
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
      }
    ]
  }])
}
