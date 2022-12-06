terraform {
  backend "s3" {
    bucket = "arghaya-upgrad-backend-tf"
    key    = "tf-state"
    region = "us-east-1"
  }
}