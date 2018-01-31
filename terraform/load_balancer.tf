resource "aws_elb" "noon-lb" {
  name               = "noon-lb"
  availability_zones = ["us-east-1a"]

  # access_logs {
  #   bucket        = "${aws_s3_bucket.elb.bucket}"
  #   bucket_prefix = "noon-elb-logs"
  #   interval      = 60
  # }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 60
  }
  security_groups             = ["${aws_security_group.allow_http.id}"]
  instances                   = ["${aws_instance.origin.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "www-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.noon-lb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}
