resource "aws_cloudwatch_metric_alarm" "api_5xx_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-api-5xx-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  statistic           = "Sum"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  threshold           = 10
  alarm_description   = "api-gateway 5xx errors elevated - burns availability SLO budget"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.api_gateway_target_group_arn_suffix
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_latency_p95" {
  alarm_name          = "${var.project_name}-${var.environment}-api-latency-p95"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  extended_statistic  = "p95"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  threshold           = 0.5
  alarm_description   = "api-gateway p95 latency over 500ms SLO target"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.api_gateway_target_group_arn_suffix
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "queue_backlog_age" {
  alarm_name          = "${var.project_name}-${var.environment}-verification-backlog-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Maximum"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  threshold           = 120
  alarm_description   = "oldest unprocessed verification job exceeds 2min SLO target"
  dimensions = {
    QueueName = var.worker_queue_name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  alarm_name          = "${var.project_name}-${var.environment}-verification-dlq-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Maximum"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  threshold           = 0
  alarm_description   = "verification jobs landing in DLQ after exhausting retries - needs investigation, not just a retry"
  dimensions = {
    QueueName = var.dlq_name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-db-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  threshold           = 80
  alarm_description   = "RDS CPU sustained above 80%"
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  threshold           = 80
  alarm_description   = "RDS connection count approaching typical instance-class limits"
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  for_each            = toset(var.ecs_service_names)
  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  threshold           = 85
  alarm_description   = "${each.key} sustained high CPU - approaching autoscaling ceiling"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = "${var.project_name}-${var.environment}-${each.key}"
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}
