########################################
# provider
########################################
provider "aws" {
  version = "~> 2.3"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "${var.aws_region}"
}

########################################
# variables
########################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "aws_az" {
  description = "The AWS AZ things are created in"
  default     = "us-east-1a"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "nginx:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "health_check_path" {
  default = "/"
}

########################################
# ecs
########################################
resource "aws_ecs_cluster" "pushaas-cluster" {
  name = "pushaas-cluster"
}

resource "aws_ecs_task_definition" "pushaas-app" {
  family                   = "pushaas-app-task"
  execution_role_arn       = "${data.aws_iam_role.task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memoryReservation": ${var.fargate_memory},
    "name": "pushaas-app",
    "networkMode": "awsvpc",
    "entryPoint": [],
    "command": [],
    "links": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/pushaas",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "pushaas-app" {
  name            = "pushaas-app-service"
  cluster         = "${aws_ecs_cluster.pushaas-cluster.id}"
  task_definition = "${aws_ecs_task_definition.pushaas-app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.pushaas-app-sg.id}"]
    subnets          = ["${aws_subnet.pushaas-public-subnet.id}"]
    assign_public_ip = true
  }
}

########################################
# logs
########################################
# Set up cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "pushaas-log-group" {
  name              = "/ecs/pushaas"
  retention_in_days = 30

  tags {
    Name = "pushaas-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "pushaas-log-stream" {
  name           = "pushaas-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.pushaas-log-group.name}"
}

########################################
# network
########################################
resource "aws_vpc" "pushaas-vpc" {
  cidr_block = "172.16.0./16"
  enable_dns_hostnames    = true
}

resource "aws_subnet" "pushaas-public-subnet" {
  vpc_id                  = "${aws_vpc.pushaas-vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.pushaas-vpc.cidr_block, 8, 0)}"
  availability_zone       = "${var.aws_az}"
  map_public_ip_on_launch = true
}

# IGW for the public subnet
resource "aws_internet_gateway" "pushaas-gw" {
  vpc_id = "${aws_vpc.pushaas-vpc.id}"
}

# Route the public subnet trafic through the IGW
resource "aws_route" "pushaas-internet-access" {
  route_table_id         = "${aws_vpc.pushaas-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.pushaas-gw.id}"
}

########################################
# roles
########################################
data "aws_iam_role" "task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "AmazonECSTaskExecutionRolePolicy"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task-execution-attach" {
  role       = "${data.aws_iam_role.task_execution_role.name}"
  policy_arn = "${aws_iam_policy.task_execution_policy.arn}"
}

########################################
# security
########################################
resource "aws_security_group" "pushaas-app-sg" {
  name        = "pushaas-app-security-group"
  description = "controls access to the pushaas app"
  vpc_id      = "${aws_vpc.pushaas-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# outputs
########################################
