resource "aws_subnet" "public_subnet" {
  vpc_id     = "${aws_vpc.noon.id}"
  cidr_block = "172.31.25.0/24",

  tags {
    Name = "Public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = "${aws_vpc.noon.id}"
  cidr_block = "172.31.24.0/24",

  tags {
    Name = "Private subnet"
  }
}