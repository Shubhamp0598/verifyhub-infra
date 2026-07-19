variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "verifyhub"
}

variable "account_alias" {
  description = "unique suffix for bucket naming (S3 bucket names are global)"
  type        = string
}
