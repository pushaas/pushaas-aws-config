########################################
# variables
########################################
# common - general
variable "aws_region" {}
variable "aws_az" {} # unused
variable "aws_profile" {}
variable "aws_credentials_file" {}

# common - pushaas
variable "pushaas_redis_count" {}
variable "pushaas_redis_image" {}
variable "pushaas_redis_port" {}
variable "pushaas_redis_fargate_cpu" {}
variable "pushaas_redis_fargate_memory" {}

# specific
variable "cluster_id" {}
variable "namespace_id" {}
variable "sg_pushaas_id" {}
variable "subnet_id" {}

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
resource "aws_ecs_task_definition" "pushaas-redis" {
  family                   = "pushaas-redis"
  execution_role_arn       = "${data.aws_iam_role.task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.pushaas_redis_fargate_cpu}"
  memory                   = "${var.pushaas_redis_fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.pushaas_redis_fargate_cpu},
    "image": "${var.pushaas_redis_image}",
    "memoryReservation": ${var.pushaas_redis_fargate_memory},
    "name": "pushaas-redis",
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
        "containerPort": ${var.pushaas_redis_port},
        "hostPort": ${var.pushaas_redis_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "pushaas-redis" {
  name            = "pushaas-redis-service"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.pushaas-redis.arn}"
  desired_count   = "${var.pushaas_redis_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${var.sg_pushaas_id}"]
    subnets          = ["${var.subnet_id}"]
    # TODO remove public ip
    assign_public_ip = true
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.pushaas-redis-service.arn}"
  }
}

########################################
# dns
########################################
resource "aws_service_discovery_service" "pushaas-redis-service" {
  name = "pushaas-redis"

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
