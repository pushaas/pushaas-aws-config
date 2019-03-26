provider "aws" {
  version = "~> 2.3"
  region     = "us-east-1"
}

resource "aws_vpc" "tcc-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "tcc-subnet" {
  vpc_id     = "${aws_vpc.tcc-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.tcc-vpc.id}"

  tags {
    Name = "VPC IGW"
  }
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.tcc-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.tcc-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}
