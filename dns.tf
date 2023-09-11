
resource "aws_route53_record" "selenium_portal" {
  zone_id = data.aws_route53_zone.selenium.id
  name    = var.selenium_portal_domain_name
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.selenium_ui.domain_name, "/[.]$/", "")
    zone_id                = aws_cloudfront_distribution.selenium_ui.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.selenium_ui]

}

resource "aws_route53_record" "load_balancer" {
  name    = var.load_balancer_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.selenium.id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.selenium.dns_name
    zone_id                = aws_alb.selenium.zone_id
  }
}