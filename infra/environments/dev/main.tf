terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "../../modules/networking"

  project_name              = var.project_name
  environment               = var.environment
  vpc_cidr                  = var.vpc_cidr
  azs                       = var.azs
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

module "ecr_api_gateway" {
  source    = "../../modules/ecr"
  repo_name = "${var.project_name}-${var.environment}-api-gateway"
}

module "ecr_worker" {
  source    = "../../modules/ecr"
  repo_name = "${var.project_name}-${var.environment}-worker"
}

module "ecr_document_service" {
  source    = "../../modules/ecr"
  repo_name = "${var.project_name}-${var.environment}-document-service"
}

module "ecr_dashboard" {
  source    = "../../modules/ecr"
  repo_name = "${var.project_name}-${var.environment}-dashboard"
}

module "ecr_admin_console" {
  source    = "../../modules/ecr"
  repo_name = "${var.project_name}-${var.environment}-admin-console"
}

module "documents" {
  source = "../../modules/s3-document-store"

  project_name = var.project_name
  environment  = var.environment
}

module "queue" {
  source = "../../modules/sqs-queue"

  project_name = var.project_name
  environment  = var.environment
}

module "cache" {
  source = "../../modules/elasticache"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_data_subnet_ids = module.networking.private_data_subnet_ids
  allowed_security_group_ids = [
    aws_security_group.worker.id,
    aws_security_group.api_gateway.id,
  ]
  node_type = var.cache_node_type
}

module "database" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_data_subnet_ids = module.networking.private_data_subnet_ids
  allowed_security_group_ids = [
    aws_security_group.worker.id,
    aws_security_group.api_gateway.id,
    aws_security_group.dashboard.id,
    aws_security_group.admin_console.id,
  ]
  instance_class        = var.db_instance_class
  multi_az              = var.db_multi_az
  deletion_protection   = var.db_deletion_protection
  backup_retention_days = var.db_backup_retention_days
}

module "iam" {
  source = "../../modules/iam"

  project_name          = var.project_name
  environment           = var.environment
  documents_bucket_arn  = module.documents.bucket_arn
  sqs_queue_arn         = module.queue.queue_arn
  db_secret_arn         = module.database.secret_arn
  documents_kms_key_arn = module.documents.kms_key_arn
  rds_kms_key_arn       = module.database.kms_key_arn
}

module "ecs_api_gateway" {
  source = "../../modules/ecs-service"

  project_name          = var.project_name
  environment           = var.environment
  service_name          = "api-gateway"
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  image_uri             = var.api_gateway_image_uri
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_app_subnet_ids
  security_group_id     = aws_security_group.api_gateway.id
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arns["api-gateway"]
  cpu                   = var.api_gateway_cpu
  memory                = var.api_gateway_memory
  desired_count         = var.api_gateway_desired_count
  min_count             = var.api_gateway_min_count
  max_count             = var.api_gateway_max_count
  publicly_reachable    = true
  alb_security_group_id = module.ecs_cluster.alb_security_group_id
  scaling_mode          = "cpu"
  env_vars = {
    QUEUE_URL = module.queue.queue_url
  }
  secrets = {
    DB_CREDENTIALS = module.database.secret_arn
  }
}

module "ecs_worker" {
  source = "../../modules/ecs-service"

  project_name       = var.project_name
  environment        = var.environment
  service_name       = "worker"
  cluster_id         = module.ecs_cluster.cluster_id
  cluster_name       = module.ecs_cluster.cluster_name
  image_uri          = var.worker_image_uri
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_app_subnet_ids
  security_group_id  = aws_security_group.worker.id
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arns["worker"]
  cpu                = var.worker_cpu
  memory             = var.worker_memory
  desired_count      = var.worker_desired_count
  min_count          = var.worker_min_count
  max_count          = var.worker_max_count
  publicly_reachable = false
  scaling_mode       = "queue"
  sqs_queue_name     = module.queue.queue_name
  env_vars = {
    QUEUE_URL        = module.queue.queue_url
    DOCUMENTS_BUCKET = module.documents.bucket_name
  }
  secrets = {
    DB_CREDENTIALS = module.database.secret_arn
  }
}

module "ecs_document_service" {
  source = "../../modules/ecs-service"

  project_name          = var.project_name
  environment           = var.environment
  service_name          = "document-service"
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  image_uri             = var.document_service_image_uri
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_app_subnet_ids
  security_group_id     = aws_security_group.document_service.id
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arns["document-service"]
  cpu                   = var.document_service_cpu
  memory                = var.document_service_memory
  desired_count         = var.document_service_desired_count
  min_count             = var.document_service_min_count
  max_count             = var.document_service_max_count
  publicly_reachable    = true
  alb_security_group_id = module.ecs_cluster.alb_security_group_id
  scaling_mode          = "cpu"
  env_vars = {
    DOCUMENTS_BUCKET = module.documents.bucket_name
  }
}

module "ecs_dashboard" {
  source = "../../modules/ecs-service"

  project_name          = var.project_name
  environment           = var.environment
  service_name          = "dashboard"
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  image_uri             = var.dashboard_image_uri
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_app_subnet_ids
  security_group_id     = aws_security_group.dashboard.id
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arns["dashboard"]
  cpu                   = var.dashboard_cpu
  memory                = var.dashboard_memory
  desired_count         = var.dashboard_desired_count
  min_count             = var.dashboard_min_count
  max_count             = var.dashboard_max_count
  publicly_reachable    = true
  alb_security_group_id = module.ecs_cluster.alb_security_group_id
  scaling_mode          = "cpu"
  secrets = {
    DB_CREDENTIALS = module.database.secret_arn
  }
}

module "ecs_admin_console" {
  source = "../../modules/ecs-service"

  project_name          = var.project_name
  environment           = var.environment
  service_name          = "admin-console"
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  image_uri             = var.admin_console_image_uri
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_app_subnet_ids
  security_group_id     = aws_security_group.admin_console.id
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arns["admin-console"]
  cpu                   = var.admin_console_cpu
  memory                = var.admin_console_memory
  desired_count         = var.admin_console_desired_count
  min_count             = var.admin_console_min_count
  max_count             = var.admin_console_max_count
  publicly_reachable    = true
  alb_security_group_id = module.ecs_cluster.alb_security_group_id
  scaling_mode          = "cpu"
  env_vars = {
    DOCUMENTS_BUCKET = module.documents.bucket_name
  }
  secrets = {
    DB_CREDENTIALS = module.database.secret_arn
  }
}

module "observability" {
  source = "../../modules/observability"

  project_name = var.project_name
  environment  = var.environment
  alarm_email  = var.alarm_email

  alb_arn_suffix                      = module.ecs_cluster.alb_arn_suffix
  api_gateway_target_group_arn_suffix = module.ecs_api_gateway.target_group_arn_suffix
  worker_queue_name                   = module.queue.queue_name
  dlq_name                            = "${var.project_name}-${var.environment}-verification-dlq"
  db_instance_id                      = "${var.project_name}-${var.environment}"
  ecs_cluster_name                    = module.ecs_cluster.cluster_name
  ecs_service_names = [
    "api-gateway", "worker", "document-service", "dashboard", "admin-console"
  ]
}
