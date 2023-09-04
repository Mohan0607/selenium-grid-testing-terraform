
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
  container_definitions = "[{\"name\":\"selenium-firefox-container\",\"image\":\"selenium/node-firefox:4.11.0\",\"cpu\":1024,\"memory\":2048,\"links\":[],\"portMappings\":[{\"containerPort\":4444,\"hostPort\":4444,\"protocol\":\"tcp\"}],\"essential\":true,\"entryPoint\":[\"sh\",\"-c\"],\"command\":[\"PRIVATE=$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]') ; export REMOTE_HOST=\\\"http://$PRIVATE:5555\\\"; export SE_OPTS=\\\"-host $PRIVATE -port 5555\\\" ; /opt/bin/entry_point.sh\"],\"environment\":[{\"name\":\"HUB_PORT_4444_TCP_ADDR\",\"value\":\"testi-Selen-N820JRLBXAA1-72390864.us-west-1.elb.amazonaws.com\"},{\"name\":\"shm_size\",\"value\":\"512\"},{\"name\":\"NODE_MAX_SESSION\",\"value\":\"500\"},{\"name\":\"HUB_PORT_4444_TCP_PORT\",\"value\":\"4444\"},{\"name\":\"NODE_MAX_INSTANCES\",\"value\":\"500\"},{\"name\":\"SE_OPTS\",\"value\":\"-debug\"}],\"environmentFiles\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[],\"dnsServers\":[],\"dnsSearchDomains\":[],\"extraHosts\":[],\"dockerSecurityOptions\":[],\"dockerLabels\":{},\"ulimits\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"testing-stack-SeleniumHubClusterseleniumfirefoxtaskdefseleniumfirefoxcontainerLogGroup40F51790-RJhH50yijzoN\",\"awslogs-region\":\"us-west-1\",\"awslogs-stream-prefix\":\"selenium-firefox-logs\"},\"secretOptions\":[]},\"systemControls\":[]}]"
  family                = join("-", [var.resource_name_prefix, "firefoxnode", "task"])
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu    = "1024"
  memory = "2048"
}
# resource "aws_ecs_task_definition" "selenium_firefox" {
#   family             = join("-", [var.resource_name_prefix, "firefoxnode", "task"])
#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   network_mode       = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu    = "1024"
#   memory = "2048"

  # container_definitions = jsonencode([{
  #   name  = "selenium-firefox-container"
  #   image = "selenium/node-firefox:4.11.0"
  #   portMappings = [{
  #     containerPort = 4444
  #     hostPort      = 4444
  #   }]
  #   environment = [
  #     # {
  #     #   name  = "HUB_PORT_4444_TCP_ADDR"
  #     #   value = "" # Update this with your Selenium Hub address
  #     # },
  #     {
  #       name  = "SE_OPTS"
  #       value = "--host selenium-hub-container --port 4444"
  #     },
  #     {
  #       name  = "HUB_PORT_4444_TCP_PORT"
  #       value = "4444" # Update this with the port your Selenium Hub is running on
  #     },
  #     {
  #       name  = "NODE_MAX_SESSION"
  #       value = "5"
  #     },
  #     {
  #       name  = "NODE_MAX_INSTANCES"
  #       value = "5"
  #     }
  #     # {
  #     #   name  = "SE_OPTS"
  #     #   value = "-debug"
  #     # }
  #   ]
  #   entryPoint = ["sh", "-c"]
  #   command = [
  #     "PRIVATE=$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]')",
  #     "export REMOTE_HOST=http://$PRIVATE:5555",
  #     "export SE_OPTS=\"-host $PRIVATE -port 5555\"",
  #     "/opt/bin/entry_point.sh"
  #   ]
  # }])
#}
