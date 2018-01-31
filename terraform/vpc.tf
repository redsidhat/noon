resource "aws_vpc" "noon" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags {
    Name = "noon"
  }
}