provider "aws" {
  version = "~> 2.3"
  region     = "us-east-1"
}

variable "aws_az" {
  description = "The AWS AZ things are created in"
  default     = "us-east-1a"
}

###################
# security
###################
resource "aws_default_security_group" "tsuru-default" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
    self      = true
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################
# network
###################
resource "aws_vpc" "tsuru-vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "tsuru"
  }
}

resource "aws_subnet" "tsuru-subnet" {
  vpc_id     = "${aws_vpc.tsuru-vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.tsuru-vpc.cidr_block, 8, 0)}"
  availability_zone = "${var.aws_az}"

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

resource "aws_route_table" "tsuru-web-public-rt" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tsuru-gw.id}"
  }

  tags {
    Name = "tsuru"
  }
}

resource "aws_route_table_association" "tsuru-web-public-rt" {
  subnet_id = "${aws_subnet.tsuru-subnet.id}"
  route_table_id = "${aws_route_table.tsuru-web-public-rt.id}"
}

###################
# output
###################
output "vpc" {
  value = "${aws_vpc.tsuru-vpc.id}"
}

output "subnet" {
  value = "${aws_subnet.tsuru-subnet.id}"
}
