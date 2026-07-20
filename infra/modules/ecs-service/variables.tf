variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "min_count" {
  type = number
}

variable "max_count" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type    = map(string)
  default = {}
}

variable "publicly_reachable" {
  type    = bool
  default = false
}

variable "target_group_arn" {
  description = "target group ARN, created at the environment root - avoids a dependency cycle with the ALB listener"
  type        = string
  default     = null
}

variable "scaling_mode" {
  type = string
  validation {
    condition     = contains(["cpu", "queue"], var.scaling_mode)
    error_message = "scaling_mode must be 'cpu' or 'queue'"
  }
}

variable "cpu_target_value" {
  type    = number
  default = 60
}

variable "sqs_queue_name" {
  type    = string
  default = null
}

variable "queue_target_backlog_per_task" {
  type    = number
  default = 10
}
