########################################
# variables
########################################
# common - general
variable "aws_region" {}
variable "aws_az" {} # unused
variable "aws_profile" {}
variable "aws_credentials_file" {}

# common - pushaas
variable "pushaas_app_count" {}
variable "pushaas_app_fargate_cpu" {}
variable "pushaas_app_fargate_memory" {}
variable "pushaas_app_image" {}
variable "pushaas_app_port" {}

# specific
variable "basic_auth_password" {}
variable "basic_auth_user" {}
variable "cluster_id" {}
variable "namespace_id" {}
variable "sg_pushaas_id" {}
variable "subnet_id" {}
variable "vpc_id" {}

########################################
# provider
########################################
provider "aws" {
  version = "~> 2.7"
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_credentials_file}"
}

########################################
# roles
########################################
data "aws_iam_role" "task_execution_role" {
  name = "ecsTaskExecutionRole"
}

########################################
# ecs
########################################
resource "aws_ecs_task_definition" "pushaas-app" {
  family                   = "pushaas-app-task"
  execution_role_arn       = "${data.aws_iam_role.task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.pushaas_app_fargate_cpu}"
  memory                   = "${var.pushaas_app_fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.pushaas_app_fargate_cpu},
    "image": "${var.pushaas_app_image}",
    "memoryReservation": ${var.pushaas_app_fargate_memory},
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
        "containerPort": ${var.pushaas_app_port},
        "hostPort": ${var.pushaas_app_port}
      }
    ],
    "environment" : [
      { "name" : "PUSHAAS_API__BASIC_AUTH_USER", "value" : "${var.basic_auth_user}" },
      { "name" : "PUSHAAS_API__BASIC_AUTH_PASSWORD", "value" : "${var.basic_auth_password}" },
      { "name" : "PUSHAAS_ENV", "value" : "prod" }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "pushaas-app" {
  name            = "pushaas-app-service"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.pushaas-app.arn}"
  desired_count   = "${var.pushaas_app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${var.sg_pushaas_id}", "${aws_security_group.pushaas-app-temp-sg.id}"]
    subnets          = ["${var.subnet_id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.pushaas-app-service.arn}"
  }
}

########################################
# dns
########################################
resource "aws_service_discovery_service" "pushaas-app-service" {
  name = "pushaas"

  dns_config {
    namespace_id = "${var.namespace_id}"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

########################################
# network
########################################
data "aws_vpc" "tsuru-vpc" {
  id = "${var.vpc_id}"
}

########################################
# security
########################################
resource "aws_security_group" "pushaas-app-temp-sg" {
  name        = "pushaas-app-temp-security-group"
  description = "controls access to the pushaas app"
  vpc_id      = "${data.aws_vpc.tsuru-vpc.id}"

  ingress {
    # TODO remove access from anywhere
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "${var.pushaas_app_port}"
    protocol    = "tcp"
    to_port     = "${var.pushaas_app_port}"
  }

  tags = {
    Name = "pushaas"
  }
}
