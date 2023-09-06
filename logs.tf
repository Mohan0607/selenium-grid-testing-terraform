locals {
  cloud_watch_log_name = join("-", [var.resource_name_prefix])
}
# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_hub" {
  name              = join("-", [local.cloud_watch_log_name, "hub", "log-group"])
  retention_in_days = 30

  tags = {
    Name = "selenium-hub-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "selenium_hub" {
  name           = join("-", [local.cloud_watch_log_name, "hub", "log-stream"])
  log_group_name = aws_cloudwatch_log_group.selenium_hub.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_chrome" {
  name              = join("-", [local.cloud_watch_log_name, "chrome", "log-group"])
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "selenium_chrome" {
  name           = join("-", [local.cloud_watch_log_name, "chrome", "log-stream"])
  log_group_name = aws_cloudwatch_log_group.selenium_chrome.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_firefox" {
  name              = join("-", [local.cloud_watch_log_name, "firefox", "log-group"])
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "selenium_firefox" {
  name           = join("-", [local.cloud_watch_log_name, "firefox", "log-stream"])
  log_group_name = aws_cloudwatch_log_group.selenium_firefox.name
}