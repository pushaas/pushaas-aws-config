########################################
# general
########################################
aws_region = "us-east-1"
aws_az = "us-east-1a"
aws_profile = "default"
aws_credentials_file = "$HOME/.aws/credentials"

########################################
# pushaas
########################################
pushaas_app_image = "nginx:latest" # TODO change for the actual app
pushaas_app_port = 80
pushaas_app_count = 1
pushaas_app_fargate_cpu = "256"
pushaas_app_fargate_memory = "512"
