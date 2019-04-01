provider "aws" {
  version = "~> 2.3"
  region     = "us-east-1"
}

###################
# security
###################
resource "aws_default_security_group" "tsuru-default" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
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
}

resource "aws_subnet" "tsuru-subnet" {
  vpc_id     = "${aws_vpc.tsuru-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "tsuru-gw" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  tags {
    Name = "VPC IGW"
  }
}

resource "aws_route_table" "tsuru-web-public-rt" {
  vpc_id = "${aws_vpc.tsuru-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tsuru-gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table_association" "tsuru-web-public-rt" {
  subnet_id = "${aws_subnet.tsuru-subnet.id}"
  route_table_id = "${aws_route_table.tsuru-web-public-rt.id}"
}

output "vpc" {
  value = "${aws_vpc.tsuru-vpc.id}"
}

output "subnet" {
  value = "${aws_subnet.tsuru-subnet.id}"
}
