resource "aws_lb" "main_alb" {
  name               = "${var.project_id}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = var.allow_http
  subnets            = var.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name        = "${var.project_id}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "main_alb_tg" {
  name     = "${var.project_id}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_id}-alb"
    Environment = var.environment
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_alb_tg.arn
  }
}
