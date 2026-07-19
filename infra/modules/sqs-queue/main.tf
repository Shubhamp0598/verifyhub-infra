resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-${var.environment}-verification-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "this" {
  name                       = "${var.project_name}-${var.environment}-verification"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = 345600 # 4 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount      = var.max_receive_count
  })
}
