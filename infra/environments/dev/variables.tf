variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "verifyhub"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "private_data_subnet_cidrs" {
  type = list(string)
}

variable "cache_node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "api_gateway_image_uri" {
  type = string
}

variable "api_gateway_cpu" {
  type    = number
  default = 512
}

variable "api_gateway_memory" {
  type    = number
  default = 1024
}

variable "api_gateway_desired_count" {
  type    = number
  default = 1
}

variable "api_gateway_min_count" {
  type    = number
  default = 1
}

variable "api_gateway_max_count" {
  type    = number
  default = 3
}

variable "worker_image_uri" {
  type = string
}

variable "worker_cpu" {
  type    = number
  default = 1024
}

variable "worker_memory" {
  type    = number
  default = 2048
}

variable "worker_desired_count" {
  type    = number
  default = 1
}

variable "worker_min_count" {
  type    = number
  default = 1
}

variable "worker_max_count" {
  type    = number
  default = 10
}

variable "document_service_image_uri" {
  type = string
}

variable "document_service_cpu" {
  type    = number
  default = 512
}

variable "document_service_memory" {
  type    = number
  default = 1024
}

variable "document_service_desired_count" {
  type    = number
  default = 1
}

variable "document_service_min_count" {
  type    = number
  default = 1
}

variable "document_service_max_count" {
  type    = number
  default = 3
}

variable "dashboard_image_uri" {
  type = string
}

variable "dashboard_cpu" {
  type    = number
  default = 256
}

variable "dashboard_memory" {
  type    = number
  default = 512
}

variable "dashboard_desired_count" {
  type    = number
  default = 1
}

variable "dashboard_min_count" {
  type    = number
  default = 1
}

variable "dashboard_max_count" {
  type    = number
  default = 2
}

variable "admin_console_image_uri" {
  type = string
}

variable "admin_console_cpu" {
  type    = number
  default = 256
}

variable "admin_console_memory" {
  type    = number
  default = 512
}

variable "admin_console_desired_count" {
  type    = number
  default = 1
}

variable "admin_console_min_count" {
  type    = number
  default = 1
}

variable "admin_console_max_count" {
  type    = number
  default = 2
}
# ci pipeline test
