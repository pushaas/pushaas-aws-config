########################################
# variables
########################################
# common - general
variable "aws_region" {}
variable "aws_az" {}
variable "aws_profile" {}
variable "aws_credentials_file" {}

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
# security
########################################
resource "aws_default_security_group" "tsuru-default" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  ingress {
    from_port = 0
    protocol  = "tcp"
    self      = true
    to_port   = 65535
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
  }

  // thanks https://blog.jwr.io/terraform/icmp/ping/security/groups/2018/02/02/terraform-icmp-rules.html
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = -1
    protocol = "icmp"
    to_port = -1
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags {
    Name = "tsuru"
  }
}

########################################
# network
########################################
resource "aws_vpc" "tsuru-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "tsuru"
  }
}

resource "aws_subnet" "tsuru-subnet" {
  vpc_id     = "${aws_vpc.tsuru-vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.tsuru-vpc.cidr_block, 8, 0)}"
  availability_zone = "${var.aws_az}"
  # TODO remove public ip
  map_public_ip_on_launch = true

  tags {
    Name = "tsuru"
  }
}

resource "aws_internet_gateway" "tsuru-gw" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  tags {
    Name = "tsuru"
  }
}

resource "aws_route_table" "tsuru-rt" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tsuru-gw.id}"
  }

  tags {
    Name = "tsuru"
  }
}

resource "aws_route_table_association" "tsuru-rt-association" {
  subnet_id = "${aws_subnet.tsuru-subnet.id}"
  route_table_id = "${aws_route_table.tsuru-rt.id}"
}

resource "aws_route" "tsuru-internet-access" {
  route_table_id         = "${aws_route_table.tsuru-rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.tsuru-gw.id}"
}

########################################
# outputs
########################################
output "vpc" {
  value = "${aws_vpc.tsuru-vpc.id}"
}

output "subnet" {
  value = "${aws_subnet.tsuru-subnet.id}"
}
