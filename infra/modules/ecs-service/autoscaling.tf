resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_count
  min_capacity       = var.min_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# steady services (api-gateway, dashboard, admin-console): scale on CPU
resource "aws_appautoscaling_policy" "cpu" {
  count              = var.scaling_mode == "cpu" ? 1 : 0
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# worker: scale on SQS backlog per task, not CPU — a burst of uploads
# should add workers before CPU even climbs, and scale back down fast
# once the queue drains
resource "aws_appautoscaling_policy" "queue" {
  count              = var.scaling_mode == "queue" ? 1 : 0
  name               = "${var.service_name}-queue-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metrics {
        label = "backlog-per-task"
        id    = "backlog_per_task"
        expression = "backlog / tasks"
        return_data = true
      }
      metrics {
        label = "backlog"
        id    = "backlog"
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = var.sqs_queue_name
            }
          }
          stat = "Average"
        }
        return_data = false
      }
      metrics {
        label = "tasks"
        id    = "tasks"
        metric_stat {
          metric {
            namespace   = "ECS/ContainerInsights"
            metric_name = "RunningTaskCount"
            dimensions {
              name  = "ServiceName"
              value = aws_ecs_service.this.name
            }
          }
          stat = "Average"
        }
        return_data = false
      }
    }
    target_value       = var.queue_target_backlog_per_task
    scale_in_cooldown  = 120
    scale_out_cooldown = 30
  }
}
