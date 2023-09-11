data "aws_acm_certificate" "selenium_ssl" {
  domain = "*.dentalxchange.com"
}

data "aws_route53_zone" "selenium" {
  name = "dentalxchange.com"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}
