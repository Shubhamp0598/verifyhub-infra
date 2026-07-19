vpc_cidr                  = "10.10.0.0/16"
azs                       = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs       = ["10.10.0.0/24", "10.10.1.0/24"]
private_app_subnet_cidrs  = ["10.10.10.0/24", "10.10.11.0/24"]
private_data_subnet_cidrs = ["10.10.20.0/24", "10.10.21.0/24"]

api_gateway_image_uri      = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-dev-api-gateway:latest"
worker_image_uri           = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-dev-worker:latest"
document_service_image_uri = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-dev-document-service:latest"
dashboard_image_uri        = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-dev-dashboard:latest"
admin_console_image_uri    = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-dev-admin-console:latest"

db_backup_retention_days = 1
