resource "aws_ecs_cluster" "selenium_grid" {
  name = join("-", [var.resource_name_prefix, "selenium-grid-cluster"])
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
  name        = join("-", [var.resource_name_prefix, "selenium-ns"])
  description = "private DNS for selenium"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "hub" {
  name = join("-", [var.resource_name_prefix, "hub-ds"])
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


# Example service discoveries for Selenium services
# resource "aws_service_discovery_service" "selenium_hub" {
#   name         = "selenium-hub"
#   namespace_id = aws_service_discovery_private_dns_namespace.selenium.id
#   dns_config {
#     dns_records {
#       ttl  = 60
#       type = "A"
#     }
#     namespace_id   = aws_service_discovery_private_dns_namespace.selenium.id
#     routing_policy = "MULTIVALUE" # Use the appropriate routing policy
#   }
# }

# resource "aws_service_discovery_service" "selenium_chrome" {
#   name         = "selenium-chrome"
#   namespace_id = aws_service_discovery_private_dns_namespace.selenium.id
#   dns_config {
#     namespace_id   = aws_service_discovery_private_dns_namespace.selenium.id
#     routing_policy = "MULTIVALUE" # Use the appropriate routing policy
#     dns_records {
#       ttl  = 60
#       type = "A"
#     }
#   }
# }

# resource "aws_service_discovery_service" "selenium_firefox" {
#   name         = "selenium-firefox"
#   namespace_id = aws_service_discovery_private_dns_namespace.selenium.id
#   dns_config {
#     dns_records {
#       ttl  = 60
#       type = "A"
#     }
#     namespace_id   = aws_service_discovery_private_dns_namespace.selenium.id
#     routing_policy = "MULTIVALUE" # Use the appropriate routing policy
#   }
# }

# resource "aws_service_discovery_instance" "selenium_hub" {
#   instance_id = "selenium-hub-instance-id"
#   service_id  = aws_service_discovery_service.selenium_hub.id

#   attributes = {
#     AWS_INSTANCE_IPV4 = "172.32.3.231"
#     custom_attribute  = "custom"
#   }
# }

# resource "aws_service_discovery_instance" "selenium_chrome" {
#   instance_id = "selenium-chrome-instance-id"
#   service_id  = aws_service_discovery_service.selenium_chrome.id

#   attributes = {
#     AWS_INSTANCE_IPV4 = "172.18.0.1"
#     custom_attribute  = "custom"
#   }
# }

# resource "aws_service_discovery_instance" "selenium_firefox" {
#   instance_id = "selenium_firefox-instance-id"
#   service_id  = aws_service_discovery_service.selenium_firefox.id

#   attributes = {
#     AWS_INSTANCE_IPV4 = "172.32.3.117"
#     custom_attribute  = "custom"
#   }
# }
