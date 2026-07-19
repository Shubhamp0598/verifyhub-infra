# execution role: what ECS itself needs (pull image, write logs, read secrets)
resource "aws_iam_role" "execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  name = "read-secrets"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
    }]
  })
}

# task role: what the APPLICATION CODE inside the container can do.
# Kept separate per-service (not one shared role) so a compromised worker
# can't touch, say, the dashboard's resources. Actual per-service policies
# are attached where each service is instantiated in the environment.
resource "aws_iam_role" "task" {
  for_each = toset(["api-gateway", "worker", "document-service", "dashboard", "admin-console"])
  name     = "${var.project_name}-${var.environment}-${each.key}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
