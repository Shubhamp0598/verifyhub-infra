resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ecs_cluster.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs_api_gateway.target_group_arn
  }
}

resource "aws_lb_listener_rule" "admin_console" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = module.ecs_admin_console.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }
}

resource "aws_lb_listener_rule" "dashboard" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = module.ecs_dashboard.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/dashboard/*"]
    }
  }
}

resource "aws_lb_listener_rule" "document_service" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = module.ecs_document_service.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/documents/*"]
    }
  }
}
