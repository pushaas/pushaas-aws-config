########################################
# variables
########################################
variable "aws_region" {}
variable "aws_profile" {}
variable "aws_credentials_file" {}

variable "pushaas_app_image" {}
variable "pushaas_app_port" {}
variable "pushaas_app_count" {}
variable "pushaas_app_fargate_cpu" {}
variable "pushaas_app_fargate_memory" {}

variable "vpc_id" {}
variable "subnet_id" {}
variable "namespace_id" {}

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
# network
########################################
data "aws_vpc" "tsuru-vpc" {
  id = "${var.vpc_id}"
}

data "aws_subnet" "tsuru-subnet" {
  id = "${var.subnet_id}"
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
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "pushaas-app" {
  name            = "pushaas-app-service"
  cluster         = "${aws_ecs_cluster.pushaas-cluster.id}"
  task_definition = "${aws_ecs_task_definition.pushaas-app.arn}"
  desired_count   = "${var.pushaas_app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.pushaas-app-sg.id}"]
    subnets          = ["${data.aws_subnet.tsuru-subnet.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.pushaas-app-service.arn}"
    # container_port = "${var.pushaas_app_port}"
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
    Name = "pushaas"
  }
}

resource "aws_cloudwatch_log_stream" "pushaas-log-stream" {
  name           = "pushaas-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.pushaas-log-group.name}"
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
  vpc_id      = "${data.aws_vpc.tsuru-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.pushaas_app_port}"
    to_port     = "${var.pushaas_app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  // thanks https://blog.jwr.io/terraform/icmp/ping/security/groups/2018/02/02/terraform-icmp-rules.html
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "pushaas"
  }
}

########################################
# outputs
########################################
# output "vpc" {
#   # value = "${aws_vpc.pushaas-vpc.id}"
#   value = "${data.aws_vpc.tsuru-vpc.id}"
# }
#
# output "subnet" {
#   value = "${aws_subnet.pushaas-subnet.id}"
# }
