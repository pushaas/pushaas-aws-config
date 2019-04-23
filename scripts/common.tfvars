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
pushaas_app_image = "rafaeleyng/pushaas:latest" # TODO change for the actual tag
pushaas_app_port = 9000
pushaas_app_count = 1
pushaas_app_fargate_cpu = "256"
pushaas_app_fargate_memory = "512"

pushaas_mongo_image = "mongo:4.0.9"
pushaas_mongo_port = 27017
pushaas_mongo_count = 1
pushaas_mongo_fargate_cpu = "256"
pushaas_mongo_fargate_memory = "512"
