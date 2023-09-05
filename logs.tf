
# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_hub" {
  name              = "selenium-hub-log-group"
  retention_in_days = 30

  tags = {
    Name = "selenium-hub-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "selenium_hub" {
  name           = "selenium-hub-log-stream"
  log_group_name = aws_cloudwatch_log_group.selenium_hub.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_chrome" {
  name              = "selenium-chrome-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "selenium_chrome" {
  name           = "selenium-chrome-log-stream"
  log_group_name = aws_cloudwatch_log_group.selenium_chrome.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "selenium_firefox" {
  name              = "selenium-firefox-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "selenium_firefox" {
  name           = "selenium-firefox-log-stream"
  log_group_name = aws_cloudwatch_log_group.selenium_firefox.name
}