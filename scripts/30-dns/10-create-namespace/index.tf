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
# dns
########################################
resource "aws_service_discovery_private_dns_namespace" "tsuru-private-namespace" {
  name        = "tsuru"
  description = "My Tsuru installation on AWS"
  vpc         = "${var.vpc_id}"
}

########################################
# outputs
########################################
output "namespace" {
  value = "${aws_service_discovery_private_dns_namespace.tsuru-private-namespace.id}"
}
