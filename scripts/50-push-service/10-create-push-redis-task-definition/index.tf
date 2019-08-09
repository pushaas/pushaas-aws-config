########################################
# variables
########################################
# common - general
variable "aws_region" {}
variable "aws_az" {} # unused
variable "aws_profile" {}
variable "aws_credentials_file" {}

# common - push-redis
variable "push_redis_image" {}
variable "push_redis_port" {}
variable "push_redis_fargate_cpu" {}
variable "push_redis_fargate_memory" {}

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
resource "aws_ecs_task_definition" "push-redis" {
  family                   = "push-redis-task"
  execution_role_arn       = "${data.aws_iam_role.task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.push_redis_fargate_cpu}"
  memory                   = "${var.push_redis_fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.push_redis_fargate_cpu},
    "image": "${var.push_redis_image}",
    "memoryReservation": ${var.push_redis_fargate_memory},
    "name": "push-redis",
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
        "containerPort": ${var.push_redis_port},
        "hostPort": ${var.push_redis_port}
      }
    ]
  }
]
DEFINITION
}
