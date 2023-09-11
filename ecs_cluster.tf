locals {
  selenium_cluster_name = join("-", [var.resource_name_prefix, "grid", "cluster"])
}

resource "aws_ecs_cluster" "selenium_grid" {
  name = local.selenium_cluster_name
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.selenium.arn
  }
  tags = {
    Name = local.selenium_cluster_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "selenium_grid" {
  cluster_name       = aws_ecs_cluster.selenium_grid.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

}

# Service Discovery (AWS Cloud Map) for a private DNS, so containers can find each other

resource "aws_service_discovery_http_namespace" "selenium" {
  #name = join("-", [var.resource_name_prefix])
  name        = "selenium"
  description = "Service Discovery for selenium"
}
