resource "aws_s3_bucket" "state_s3" {
  bucket = "s3-state-file-bucket"

  tags = {
    Name        = "S3 Statefile"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.state_s3.id
  acl    = "private"
}