resource "aws_lb_target_group" "api_gateway" {
  name_prefix = "apigw-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "admin_console" {
  name_prefix = "admin-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "dashboard" {
  name_prefix = "dash-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "document_service" {
  name_prefix = "docsv-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}
