resource "aws_security_group_rule" "alb_to_api_gateway" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api_gateway.id
  source_security_group_id = module.ecs_cluster.alb_security_group_id
}

resource "aws_security_group_rule" "alb_to_admin_console" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.admin_console.id
  source_security_group_id = module.ecs_cluster.alb_security_group_id
}

resource "aws_security_group_rule" "alb_to_dashboard" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dashboard.id
  source_security_group_id = module.ecs_cluster.alb_security_group_id
}

resource "aws_security_group_rule" "alb_to_document_service" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.document_service.id
  source_security_group_id = module.ecs_cluster.alb_security_group_id
}
