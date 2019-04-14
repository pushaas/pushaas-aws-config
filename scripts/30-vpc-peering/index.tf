//connections.tf
provider "aws" {
  region = "us-east-1"
  version = "~> 2.5"
}

variable "VPC_TSURU" {}
variable "SUBNET_TSURU" {}
variable "VPC_PUSHAAS" {}
variable "SUBNET_PUSHAAS" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "tsuru-vpc" {
  id = "${var.VPC_TSURU}"
}

data "aws_vpc" "pushaas-vpc" {
  id = "${var.VPC_PUSHAAS}"
}

data "aws_route_table" "tsuru-rt" {
  subnet_id = "${var.SUBNET_TSURU}"
}

data "aws_route_table" "pushaas-rt" {
  subnet_id = "${var.SUBNET_PUSHAAS}"
}

########################################
# peering
########################################
resource "aws_vpc_peering_connection" "tsuru2pushaas" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  vpc_id        = "${data.aws_vpc.tsuru-vpc.id}"
  peer_vpc_id   = "${data.aws_vpc.pushaas-vpc.id}"
  auto_accept   = true
}

resource "aws_route" "tsuru2pushaas" {
  route_table_id = "${data.aws_route_table.tsuru-rt.id}"
  destination_cidr_block = "${data.aws_vpc.pushaas-vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.tsuru2pushaas.id}"
}

resource "aws_route" "pushaas2tsuru" {
  route_table_id = "${data.aws_route_table.pushaas-rt.id}"
  destination_cidr_block = "${data.aws_vpc.tsuru-vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.tsuru2pushaas.id}"
}

########################################
# outputs
########################################
# output "vpc" {
#   value = "${data.aws_vpc.tsuru-vpc.id}"
# }
#
# output "subnet" {
#   value = "${data.aws_vpc.pushaas-vpc.id}"
# }

# output "aws_caller_identity_current" {
#   value = "${data.aws_caller_identity.current.account_id}"
# }
