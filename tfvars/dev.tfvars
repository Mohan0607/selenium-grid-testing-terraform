# Project
local_aws_profile_name = "default"
region                 = "us-west-2"

# Env
resource_name_prefix = "dentalx-selenium"

# Tags
project_resource_administrator = "Avinash Manjunath"
project_name                   = "Selenium Grid"

vpc_id = "vpc-072ea10fe0bff3c31"

public_subnet_ids  = ["subnet-0840c95936a15f882", "subnet-0c4e0ceb1ff382982"]
private_subnet_ids = ["subnet-0c51bd6f26b742aca", "subnet-046f874c7f4210565"]

#S3

bucket_name = "portal"

# DNS

load_balancer_domain_name = "selenium.dentalxchange.com"

# Cloud Front

selenium_cf_aliases         = ["selenium.dentalxchange.com"]
selenium_portal_domain_name = "selenium.dentalxchange.com"
cloufront_acm_cert_arn      = "arn:aws:acm:us-east-1:791768447655:certificate/e5593d44-530a-4f40-8a26-5d4098b5a7df"

# ECS Firefox Task Definitions

selenium_firefox_image                 = "selenium/node-firefox:4.11.0"
selenium_firefox_task_cpu              = 1024
selenium_firefox_task_memory           = 2048
selenium_firefox_container_cpu         = 1024
selenium_firefox_container_memory      = 2048
selenium_firefox_service_desired_count = 1
selenium_firefox_log_configuration = {
  "logDriver" = "awslogs",
  "options" = {
    "awslogs-create-group"  = "true",
    "awslogs-group"         = "dxc-selenium-firefox-log-group",
    "awslogs-region"        = "us-west-2",
    "awslogs-stream-prefix" = "firefox"
  }
}

# ECS Chrome Task Definitions

selenium_chrome_image                 = "selenium/node-chrome:4.11.0"
selenium_chrome_task_cpu              = 1024
selenium_chrome_task_memory           = 2048
selenium_chrome_container_cpu         = 1024
selenium_chrome_container_memory      = 2048
selenium_chrome_service_desired_count = 1
selenium_chrome_log_configuration = {
  "logDriver" = "awslogs",
  "options" = {
    "awslogs-create-group"  = "true",
    "awslogs-group"         = "dxc-selenium-chrome-log-group",
    "awslogs-region"        = "us-west-2",
    "awslogs-stream-prefix" = "chrome"
  }
}

# ECS Hub Task Definitions

selenium_hub_image                 = "selenium/hub:4.11.0"
selenium_hub_task_cpu              = 1024
selenium_hub_task_memory           = 2048
selenium_hub_container_cpu         = 1024
selenium_hub_container_memory      = 2048
selenium_hub_service_desired_count = 1
selenium_hub_log_configuration = {
  "logDriver" = "awslogs",
  "options" = {
    "awslogs-create-group"  = "true",
    "awslogs-group"         = "dxc-selenium-hub-log-group",
    "awslogs-region"        = "us-west-2",
    "awslogs-stream-prefix" = "hub"
  }
}