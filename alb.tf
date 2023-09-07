
resource "aws_alb" "selenium" {
  name            = join("-", [var.resource_name_prefix, "alb"])
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id, aws_security_group.ecs_tasks.id]
}

resource "aws_alb_target_group" "selenium" {
  name        = join("-", [var.resource_name_prefix, "hub", "tg"])
  port        = local.selenium_hub_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 5
    interval            = 180
    protocol            = "HTTP"
    port                = "4444"
    matcher             = "200"
    timeout             = 5
    path                = "/ui"
    unhealthy_threshold = 2
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "selenium" {
  load_balancer_arn = aws_alb.selenium.id
  port              = 80
  protocol          = "HTTP"
  # default_action {
  #   target_group_arn = aws_alb_target_group.selenium.arn
  #   type             = "forward"
  # }
  # default_action {
  #   type             = "redirect"
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }
}

# Redirect all traffic from the ALB to the target group
# resource "aws_alb_listener" "selenium_ssl" {
#   load_balancer_arn = aws_alb.selenium.id
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn = data.aws_acm_certificate.selenium_ssl.arn
#   default_action {
#     target_group_arn = aws_alb_target_group.selenium.arn
#     type             = "forward"
#   }
  
# }

# resource "aws_lb_listener_rule" "eligibility_api" {
#   listener_arn = aws_lb_listener.selenium_ssl.arn
#   priority     = 3

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.eligibility_api.arn
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/v1/eligibility*"
#       ]
#     }
#   }

#   condition {
#     http_header {
#       http_header_name = "x-front-internal-auth"
#       values = [
#         random_uuid.api_gw_alb_token.result,
#       ]
#     }
#   }
# }


# data "aws_acm_certificate" "selenium_ssl" {
#   domain = "*.dentalxchange.com"
# }