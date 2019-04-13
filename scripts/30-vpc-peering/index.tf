//connections.tf
provider "aws" {
  region = "us-east-1"
  version = "~> 2.5"
}

//variables.tf
variable "ami_name" {
  default = "Amazon Linux 2"
}

variable "ami_id" {
  default = "ami-0de53d8956e8dcf80"
}

variable "az" {
  default = "us-east-1a"
}

variable "ami_key_pair_name" {
  default = "rafaeleyng"
}

######################################
# peer 1
######################################
//network.tf
resource "aws_vpc" "vpc-peer1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "peer1"
  }
}

resource "aws_eip" "eip-peer1" {
  instance = "${aws_instance.instance-peer1-1.id}"
  vpc      = true
}

//subnets.tf
resource "aws_subnet" "subnet-peer1" {
  cidr_block = "${cidrsubnet(aws_vpc.vpc-peer1.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.vpc-peer1.id}"
  availability_zone = "${var.az}"
}

//subnets.tf
resource "aws_route_table" "rt-peer1" {
  vpc_id = "${aws_vpc.vpc-peer1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw-peer1.id}"
  }

  tags {
    Name = "rt-peer1"
  }
}

resource "aws_route_table_association" "sa-peer1" {
  subnet_id      = "${aws_subnet.subnet-peer1.id}"
  route_table_id = "${aws_route_table.rt-peer1.id}"
}

//security.tf
resource "aws_security_group" "ingress-all-peer1" {
  name = "ingress-all-peer1"
  vpc_id = "${aws_vpc.vpc-peer1.id}"

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

  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

//servers.tf
resource "aws_instance" "instance-peer1-1" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.ingress-all-peer1.id}"]

  tags {
    Name = "${var.ami_name}"
  }

  subnet_id = "${aws_subnet.subnet-peer1.id}"
}

resource "aws_instance" "instance-peer1-2" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.ingress-all-peer1.id}"]

  tags {
    Name = "${var.ami_name}"
  }

  subnet_id = "${aws_subnet.subnet-peer1.id}"
}

//gateways.tf
resource "aws_internet_gateway" "gw-peer1" {
  vpc_id = "${aws_vpc.vpc-peer1.id}"

  tags {
    Name = "gw-peer1"
  }
}

//outputs.tf
output "eip-peer1-1-public-ip" {
  value = "${aws_eip.eip-peer1.public_ip}"
}

output "eip-peer1-2-private-ip" {
  value = "${aws_instance.instance-peer1-2.private_ip}"
}

######################################
# peer 2
######################################
//network.tf
resource "aws_vpc" "vpc-peer2" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "peer2"
  }
}

resource "aws_eip" "eip-peer2" {
  instance = "${aws_instance.instance-peer2.id}"
  vpc      = true
}

//subnets.tf
resource "aws_subnet" "subnet-peer2" {
  cidr_block = "${cidrsubnet(aws_vpc.vpc-peer2.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.vpc-peer2.id}"
  availability_zone = "${var.az}"
}

//subnets.tf
resource "aws_route_table" "rt-peer2" {
  vpc_id = "${aws_vpc.vpc-peer2.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw-peer2.id}"
  }

  tags {
    Name = "rt-peer2"
  }
}

resource "aws_route_table_association" "sa-peer2" {
  subnet_id      = "${aws_subnet.subnet-peer2.id}"
  route_table_id = "${aws_route_table.rt-peer2.id}"
}

//security.tf
resource "aws_security_group" "ingress-all-peer2" {
  name = "ingress-all-peer2"
  vpc_id = "${aws_vpc.vpc-peer2.id}"

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

  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

//servers.tf
resource "aws_instance" "instance-peer2" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.ingress-all-peer2.id}"]

  tags {
    Name = "${var.ami_name}"
  }

  subnet_id = "${aws_subnet.subnet-peer2.id}"
}

//gateways.tf
resource "aws_internet_gateway" "gw-peer2" {
  vpc_id = "${aws_vpc.vpc-peer2.id}"

  tags {
    Name = "gw-peer2"
  }
}

//outputs.tf
output "eip-peer2-public-ip" {
  value = "${aws_eip.eip-peer2.public_ip}"
}

output "eip-peer2-private-ip" {
  value = "${aws_instance.instance-peer2.private_ip}"
}

######################################
# peering
######################################
data "aws_caller_identity" "current" {}

output "aws_caller_identity_current" {
  value = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_vpc_peering_connection" "primary2secondary" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "${aws_vpc.vpc-peer2.id}"
  vpc_id        = "${aws_vpc.vpc-peer1.id}"
  auto_accept   = true
  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }
  #
  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }
}

resource "aws_route" "primary2secondary" {
  # route_table_id = "${aws_vpc.vpc-peer1.main_route_table_id}"
  route_table_id = "${aws_route_table.rt-peer1.id}"
  destination_cidr_block = "${aws_vpc.vpc-peer2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}

resource "aws_route" "secondary2primary" {
  # route_table_id = "${aws_vpc.vpc-peer2.main_route_table_id}"
  route_table_id = "${aws_route_table.rt-peer2.id}"
  destination_cidr_block = "${aws_vpc.vpc-peer1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}
