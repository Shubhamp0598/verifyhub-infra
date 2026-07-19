environment                = "staging"
vpc_cidr                   = "10.20.0.0/16"
azs                        = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs        = ["10.20.0.0/24", "10.20.1.0/24"]
private_app_subnet_cidrs   = ["10.20.10.0/24", "10.20.11.0/24"]
private_data_subnet_cidrs  = ["10.20.20.0/24", "10.20.21.0/24"]
