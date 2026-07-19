variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alarm_email" {
  description = "email to subscribe to alarm notifications - leave empty to skip"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  type = string
}

variable "api_gateway_target_group_arn_suffix" {
  type = string
}

variable "worker_queue_name" {
  type = string
}

variable "dlq_name" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_names" {
  description = "list of ECS service names to alarm on (CPU/memory)"
  type        = list(string)
}
