resource "aws_ecs_cluster" "selenium_grid" {
  name = join("-", [var.resource_name_prefix, "grid", "cluster"])
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

## Service Discovery (AWS Cloud Map) for a private DNS, so containers can find each other

resource "aws_service_discovery_private_dns_namespace" "selenium" {
  #name        = join("-", [var.resource_name_prefix, "dns"])
  name        = "selenium"
  description = "private DNS for selenium"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "hub" {
  #name = join("-", [var.resource_name_prefix, "dns", "hub"])
  name = "hub"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.selenium.id
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
