locals {
  selenium_firefox_container_port = 5555
  selenium_firefox_container_name = join("-", [var.resource_name_prefix, "firefox-container"])
  selenium_firefox_envs           = concat(local.node_environments)

  selenium_firefox_container_definition = [
    {
      name         = local.selenium_firefox_container_name
      image        = var.selenium_firefox_image
      memory       = var.selenium_firefox_container_memory
      cpu          = var.selenium_firefox_container_cpu
      essential    = true
      command      = ["/bin/bash", "-c", "PRIVATE=$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]') ; export SE_OPTS=\"--host $PRIVATE\" ; /opt/bin/entry_point.sh"]
      entryPoint   = []
      mountPoints  = []
      volumesFrom  = []
      portMappings = []
      environment  = local.selenium_firefox_envs
      portMappings = [
        {
          name          = local.selenium_firefox_container_name
          containerPort = local.selenium_firefox_container_port
          hostPort      = local.selenium_firefox_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "${aws_cloudwatch_log_group.selenium_firefox.name}",
          "awslogs-region"        = "${var.region}",
          "awslogs-stream-prefix" = "firefox"
        }
      }
      #logConfiguration = var.selenium_firefox_log_configuration
  }]

}


resource "aws_ecs_service" "selenium_firefox" {
  name            = join("-", [local.selenium_ecs_name_prefix, "firefox", "service"])
  cluster         = aws_ecs_cluster.selenium_grid.id
  desired_count   = var.selenium_firefox_service_desired_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.selenium_firefox.arn
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.private_subnet_ids
  }
  service_connect_configuration {
    namespace = aws_service_discovery_http_namespace.selenium.arn
    enabled   = true
  }
  tags = {
    Name = join("-", [local.selenium_ecs_name_prefix, "firefox", "service"])
  }
  depends_on = [aws_ecs_service.selenium_hub]

}
resource "aws_ecs_task_definition" "selenium_firefox" {
  family                   = join("-", [local.selenium_ecs_name_prefix, "firefox", "task"])
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.selenium_firefox_task_cpu
  memory                   = var.selenium_firefox_task_memory
  container_definitions    = jsonencode(concat(local.selenium_firefox_container_definition))

  tags = {
    Name = join("-", [local.selenium_ecs_name_prefix, "firefox", "task"])
  }
}


resource "aws_appautoscaling_target" "firefox_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
  tags = {
    Name = join("-", [var.resource_name_prefix, "selenium", "firefox", "auto-target"])
  }
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "firefox_up" {
  name              = join("-", [local.selenium_ecs_name_prefix, "firefox", "scale", "down"])
  service_namespace = aws_appautoscaling_target.firefox_target.service_namespace

  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 60
      scaling_adjustment          = 3
    }
  }
  depends_on = [aws_appautoscaling_target.firefox_target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "firefox_down" {
  name              = join("-", [local.selenium_ecs_name_prefix, "firefox", "scale", "down"])
  service_namespace = aws_appautoscaling_target.firefox_target.service_namespace

  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 30
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.firefox_target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "firefox_service_cpu_high" {
  alarm_name          = join("-", [local.selenium_ecs_name_prefix, "firefox", "utilization", "high"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_firefox.name
  }
  tags = {
    Name = join("-", [local.selenium_ecs_name_prefix, "firefox", "utilization", "high"])
  }
  alarm_actions = [aws_appautoscaling_policy.firefox_up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "firefox_service_cpu_low" {
  alarm_name          = join("-", [local.selenium_ecs_name_prefix, "firefox", "utilization", "low"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_firefox.name
  }
  tags = {
    Name = join("-", [local.selenium_ecs_name_prefix, "firefox", "utilization", "low"])
  }
  alarm_actions = [aws_appautoscaling_policy.firefox_down.arn]
}
