########################################
# lb
########################################
resource "aws_lb" "pushaas-app-lb" {
  name            = "pushaas-app-load-balancer"
  load_balancer_type = "application"
  subnets         = ["${aws_subnet.pushaas-public-subnet.*.id}"]
  security_groups = ["${aws_security_group.pushaas-app-lb-sg.id}"]
}

resource "aws_lb_target_group" "pushaas-app" {
  name        = "pushaas-app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.pushaas-vpc.id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "${var.health_check_path}"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the LB to the target group
resource "aws_lb_listener" "pushaas-app" {
  load_balancer_arn = "${aws_lb.pushaas-app-lb.id}"
  port              = "${var.app_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.pushaas-app.id}"
    type             = "forward"
  }
}

########################################
# ecs
########################################
data "template_file" "pushaas_app" {
  template = "${file("templates/ecs/pushaas.json.tpl")}"

  vars {
    app_image      = "${var.app_image}"
    app_port       = "${var.app_port}"
    aws_region     = "${var.aws_region}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
  }
}

resource "aws_ecs_cluster" "pushaas-cluster" {
  name = "pushaas-cluster"
}

resource "aws_ecs_task_definition" "pushaas-app" {
  family                   = "pushaas-app-task"
  execution_role_arn       = "${aws_iam_role.task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.pushaas_app.rendered}"
}

resource "aws_ecs_service" "pushaas-app" {
  name            = "pushaas-app-service"
  cluster         = "${aws_ecs_cluster.pushaas-cluster.id}"
  task_definition = "${aws_ecs_task_definition.pushaas-app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.pushaas-ecs-tasks-sg.id}"]
    subnets          = ["${aws_subnet.pushaas-private-subnet.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.pushaas-app.id}"
    container_name   = "pushaas-app"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.pushaas-app",
  ]
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
# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "pushaas-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "pushaas-private-subnet" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.pushaas-vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.pushaas-vpc.id}"
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "pushaas-public-subnet" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc.pushaas-vpc.cidr_block, 8, var.az_count + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id                  = "${aws_vpc.pushaas-vpc.id}"
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

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "pushaas-eip" {
  count      = "${var.az_count}"
  vpc        = true
  depends_on = ["aws_internet_gateway.pushaas-gw"]
}

resource "aws_nat_gateway" "pushaas-nat-gw" {
  count         = "${var.az_count}"
  subnet_id     = "${element(aws_subnet.pushaas-public-subnet.*.id, count.index)}"
  allocation_id = "${element(aws_eip.pushaas-eip.*.id, count.index)}"
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "pushaas-private-rt" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.pushaas-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.pushaas-nat-gw.*.id, count.index)}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "pushaas-rt-association" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.pushaas-private-subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.pushaas-private-rt.*.id, count.index)}"
}

########################################
# outputs
########################################
output "pushaas-app-lb-hostname" {
  value = "${aws_lb.pushaas-app-lb.dns_name}"
}

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
# roles
########################################
resource "aws_iam_role" "task_execution_role" {
  name = "fargate-task-execution-role"
  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "fargate-task-execution-policy"
  path        = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task-execution-attach" {
  depends_on = ["aws_iam_role.task_execution_role"]
  role       = "${aws_iam_role.task_execution_role.name}"
  policy_arn = "${aws_iam_policy.task_execution_policy.arn}"
}

########################################
# security
########################################
# LB Security Group: Edit this to restrict access to the application
resource "aws_security_group" "pushaas-app-lb-sg" {
  name        = "pushaas-app-load-balancer-security-group"
  description = "controls access to the LB"
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

# Traffic to the ECS cluster should only come from the LB
resource "aws_security_group" "pushaas-ecs-tasks-sg" {
  name        = "pushaas-ecs-tasks-sg"
  description = "allow inbound access from the LB only"
  vpc_id      = "${aws_vpc.pushaas-vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.pushaas-app-lb-sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# variables
########################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "aws_az" {
  description = "The AWS availability zone"
  default     = "us-east-1a"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "nginx:alpine"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "health_check_path" {
  default = "/"
}
