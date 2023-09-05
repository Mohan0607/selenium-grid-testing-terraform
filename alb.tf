
resource "aws_alb" "main" {
  name    = join("-", [var.resource_name_prefix, "load-balancer"])
  subnets = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id,
  aws_security_group.ecs_tasks.id]
}

resource "aws_alb_target_group" "app" {
  name        = join("-", [var.resource_name_prefix, "hub-target-group"])
  port        = 4444
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
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

