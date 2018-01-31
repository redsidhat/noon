resource "aws_s3_bucket" "elb" {
  bucket = "noon-s3"
  acl    = "private"

  tags {
    Name        = "Noon Bucket"
    Environment = "Dev"
  }
}