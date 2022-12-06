terraform {
  backend "s3" {
    bucket = "arghaya-s3-state-file-bucket"
    key    = "tf-state"
    region = "us-east-1"
  }
}