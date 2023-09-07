locals {
  seleium_ecs_name_prefix = join("-", [var.resource_name_prefix, "selenium"])

  selenium_hub_container_port = 4444
  selenium_hub_container_name = "selenium-hub-container"

  selenium_hub_container_definition = [
    {
      name         = local.selenium_hub_container_name
      image        = var.selenium_hub_image
      memory       = var.selenium_hub_container_memory
      cpu          = var.selenium_hub_container_cpu
      essential    = true
      command      = []
      entryPoint   = []
      mountPoints  = []
      volumesFrom  = []
      portMappings = []
      environment  = []
      portMappings = [
        {
          containerPort = local.selenium_hub_container_port
          hostPort      = local.selenium_hub_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = var.selenium_hub_log_configuration
  }]

}

resource "aws_ecs_service" "selenium_hub" {
  name    = join("-", [local.seleium_ecs_name_prefix, "hub", "service"])
  cluster = aws_ecs_cluster.selenium_grid.id

  desired_count                     = 1
  launch_type                       = "FARGATE"
  task_definition                   = aws_ecs_task_definition.selenium_hub.arn
  health_check_grace_period_seconds = 300
  scheduling_strategy               = "REPLICA"
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.private_subnet_ids

  }
  service_registries {
    registry_arn   = aws_service_discovery_service.hub.arn
    container_name = local.selenium_hub_container_name
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.selenium.arn
    container_name   = local.selenium_hub_container_name
    container_port   = local.selenium_hub_container_port
  }
  tags = {
    Name = join("-", [local.seleium_ecs_name_prefix, "hub", "service"])
  }
  depends_on = [aws_alb_listener.selenium, aws_iam_role_policy_attachment.ecs_task_execution_role]

}

resource "aws_ecs_task_definition" "selenium_hub" {
  family                   = join("-", [local.seleium_ecs_name_prefix, "hub", "task"])
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.selenium_hub_task_cpu
  memory                   = var.selenium_hub_task_memory
  container_definitions    = jsonencode(concat(local.selenium_hub_container_definition))
  #   container_definitions = <<DEFINITION
  # [
  #    {
  #         "name": "selenium-hub-container", 
  #         "image": "selenium/hub:4.11.0", 
  #         "portMappings": [
  #             {
  #             "hostPort": 4444,
  #             "protocol": "tcp",
  #             "containerPort": 4444
  #             }
  #         ], 
  #         "essential": true, 
  #         "entryPoint": [], 
  #         "command": [],
  #         "logConfiguration": {
  #                 "logDriver": "awslogs",
  #                 "options": {
  #                     "awslogs-create-group":"true",
  #                     "awslogs-group": "selenium-hub-log-group",
  #                     "awslogs-region": "us-west-2",
  #                     "awslogs-stream-prefix": "hub"
  #                 }
  #             }
  #     }
  # ]
  # DEFINITION
  tags = {
    Name = join("-", [local.seleium_ecs_name_prefix, "hub", "task"])
  }
}

resource "aws_appautoscaling_target" "hub_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_hub.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
  tags = {
    Name = join("-", [var.resource_name_prefix, "selenium", "hub", "auto-target"])
  }
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "hub_up" {
  name               = join("-", [local.seleium_ecs_name_prefix, "scale", "up"])
  service_namespace  = aws_appautoscaling_target.hub_target.service_namespace
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_hub.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.hub_target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "hub_down" {
  name               = join("-", [local.seleium_ecs_name_prefix, "scale", "down"])
  service_namespace  = aws_appautoscaling_target.hub_target.service_namespace
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_hub.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.hub_target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "hub_service_cpu_high" {
  alarm_name          = join("-", [local.seleium_ecs_name_prefix, "hub", "utilization", "high"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_hub.name
  }
  tags = {
    Name = join("-", [local.seleium_ecs_name_prefix, "hub", "utilization", "high"])
  }
  alarm_actions = [aws_appautoscaling_policy.hub_up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "hub_service_cpu_low" {
  alarm_name          = join("-", [local.seleium_ecs_name_prefix, "hub", "utilization", "low"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_hub.name
  }
  tags = {
    Name = join("-", [local.seleium_ecs_name_prefix, "hub", "utilization", "low"])
  }
  alarm_actions = [aws_appautoscaling_policy.hub_down.arn]
}

