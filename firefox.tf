locals {
  chrome_node_prefix = join("-", [var.resource_name_prefix, "chrome", ])
}
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
    subnets         = var.private_subnet_ids
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
                    "awslogs-region": "us-west-2",
                    "awslogs-stream-prefix": "firefox"
                }
            }
        }
]
DEFINITION
}


resource "aws_appautoscaling_target" "firefox_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "firefox_up" {
  name              = join("-", [local.firefox_node_prefix, "scale", "down"])
  service_namespace = aws_appautoscaling_target.firefox_target.service_namespace

  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
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

  depends_on = [aws_appautoscaling_target.firefox_target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "firefox_down" {
  name              = join("-", [local.firefox_node_prefix, "scale", "down"])
  service_namespace = aws_appautoscaling_target.firefox_target.service_namespace

  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_firefox.name}"
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

  depends_on = [aws_appautoscaling_target.firefox_target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = join("-", [local.firefox_node_prefix, "utilization", "high"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_firefox.name
  }

  alarm_actions = [aws_appautoscaling_policy.firefox_up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = join("-", [local.firefox_node_prefix, "utilization", "low"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.selenium_grid.name
    ServiceName = aws_ecs_service.selenium_firefox.name
  }

  alarm_actions = [aws_appautoscaling_policy.firefox_down.arn]
}
