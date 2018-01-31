output "origin_ip" {
    value = ["${aws_instance.origin.*.public_ip}"]
}
output "elb_dns" {
    value = ["${aws_elb.noon-lb.dns_name}"]
}
