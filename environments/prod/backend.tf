terraform {
  backend "s3" {
    bucket         = "gokulsnew-s3-us-east-2"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}