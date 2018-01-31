
resource "aws_instance" "origin" {
    availability_zone = "us-east-1a"
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    associate_public_ip_address = "true"
    security_groups = ["allow_ssh", "allow_https", "allow_http"]
    key_name = "${aws_key_pair.server-key.key_name}"
    count = "${var.origin-count}"
    tags {
        Name = "origin-${count.index}"
    }
}
