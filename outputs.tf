
output "alb_hostname" {
  value = aws_alb.selenium.dns_name
}

