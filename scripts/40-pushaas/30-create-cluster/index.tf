########################################
# variables
########################################
# common - general
variable "aws_region" {}
variable "aws_az" {} # unused
variable "aws_profile" {}
variable "aws_credentials_file" {}

# specific
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
# network
########################################
data "aws_vpc" "tsuru-vpc" {
  id = "${var.vpc_id}"
}

########################################
# ecs
########################################
resource "aws_ecs_cluster" "pushaas-cluster" {
  name = "pushaas-cluster"
}

########################################
# logs
########################################
# Set up cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "pushaas-log-group" {
  name              = "/ecs/pushaas"
  retention_in_days = 30

  tags = {
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
    from_port = 0
    protocol  = "tcp"
    self      = true
    to_port   = 65535
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  // thanks https://blog.jwr.io/terraform/icmp/ping/security/groups/2018/02/02/terraform-icmp-rules.html
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = -1
    protocol = "icmp"
    to_port = -1
  }

  # TODO remove access from anywhere - this is here just to ease testing until the system is mature
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name = "pushaas"
  }
}

########################################
# outputs
########################################
output "cluster_id" {
  value = "${aws_ecs_cluster.pushaas-cluster.id}"
}

output "sg_pushaas_id" {
  value = "${aws_security_group.pushaas-app-sg.id}"
}
