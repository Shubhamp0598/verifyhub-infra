environment               = "prod"
vpc_cidr                  = "10.30.0.0/16"
azs                       = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs       = ["10.30.0.0/24", "10.30.1.0/24"]
private_app_subnet_cidrs  = ["10.30.10.0/24", "10.30.11.0/24"]
private_data_subnet_cidrs = ["10.30.20.0/24", "10.30.21.0/24"]

api_gateway_image_uri      = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-prod-api-gateway:latest"
worker_image_uri           = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-prod-worker:latest"
document_service_image_uri = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-prod-document-service:latest"
dashboard_image_uri        = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-prod-dashboard:latest"
admin_console_image_uri    = "015989496267.dkr.ecr.us-east-1.amazonaws.com/verifyhub-prod-admin-console:latest"

db_multi_az            = true
db_deletion_protection = true
worker_max_count       = 20
