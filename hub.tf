locals {
  task_definition = {
    name : "selenium-hub-container",
    image : "selenium/hub:4.11.0",
    cpu : 1024
    memory : 2048,
    networkMode : "awsvpc",
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        "awslogs-group" : "selenium-hub-log-group",
        "awslogs-region" : "us-west-2",
        "awslogs-stream-prefix" : "hub",
      }
    },
    portMappings : [
      {
        containerPort : 4444,
        hostPort : 4444
      }
    ]
  }
}

resource "aws_ecs_service" "selenium_hub" {
  name    = join("-", [var.resource_name_prefix, "hub"])
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
    container_name = "selenium-hub-container"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "selenium-hub-container"
    container_port   = 4444
  }
  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]

}

resource "aws_ecs_task_definition" "selenium_hub" {
  #container_definitions    = data.template_file.cb_app.rendered
  #container_definitions = "[{\"name\":\"selenium-hub-container\",\"image\":\"selenium/hub:4.11.0\",\"cpu\":1024,\"memory\":2048,\"links\":[],\"portMappings\":[{\"containerPort\":4444,\"hostPort\":4444,\"protocol\":\"tcp\"},{\"containerPort\":5555,\"hostPort\":5555,\"protocol\":\"tcp\"},{\"containerPort\":4443,\"hostPort\":4443,\"protocol\":\"tcp\"},{\"containerPort\":4442,\"hostPort\":4442,\"protocol\":\"tcp\"}],\"essential\":true,\"entryPoint\":[],\"command\":[],\"environment\":[{\"name\":\"SE_OPTS\",\"value\":\"--log-level FINE\"}],\"environmentFiles\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[],\"dnsServers\":[],\"dnsSearchDomains\":[],\"extraHosts\":[],\"dockerSecurityOptions\":[],\"dockerLabels\":{},\"ulimits\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"ecs-app\",\"awslogs-region\":\"us-west-1\",\"awslogs-stream-prefix\":\"cb-log-stream\"},\"secretOptions\":[]},\"systemControls\":[]}]"
  family             = join("-", [var.resource_name_prefix, "hub", "task"])
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu                   = "1024"
  memory                = "2048"
  container_definitions = <<DEFINITION
[
   {
        "name": "selenium-hub-container", 
        "image": "selenium/hub:4.11.0", 
        "portMappings": [
            {
            "hostPort": 4444,
            "protocol": "tcp",
            "containerPort": 4444
            }
        ], 
        "essential": true, 
        "entryPoint": [], 
        "command": [],
        "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group":"true",
                    "awslogs-group": "selenium-hub-log-group",
                    "awslogs-region": "us-west-2",
                    "awslogs-stream-prefix": "hub"
                }
            }
    }
]
DEFINITION
}

resource "aws_appautoscaling_target" "hub_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.selenium_grid.name}/${aws_ecs_service.selenium_hub.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "hub_up" {
  name               = "hub_scale_up"
  service_namespace  = "ecs"
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
  name               = "hub_scale_down"
  service_namespace  = "ecs"
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

# # CloudWatch alarm that triggers the autoscaling up policy
# resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
#   alarm_name          = "cb_cpu_utilization_high"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "85"

#   dimensions = {
#     ClusterName = aws_ecs_cluster.selenium_grid.name
#     ServiceName = aws_ecs_service.selenium_hub.name
#   }

#   alarm_actions = [aws_appautoscaling_policy.up.arn]
# }

# # CloudWatch alarm that triggers the autoscaling down policy
# resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
#   alarm_name          = "cb_cpu_utilization_low"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "10"

#   dimensions = {
#     ClusterName = aws_ecs_cluster.selenium_grid.name
#     ServiceName = aws_ecs_service.selenium_hub.name
#   }

#   alarm_actions = [aws_appautoscaling_policy.down.arn]
# }

