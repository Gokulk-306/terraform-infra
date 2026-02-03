terraform {
  backend "s3" {
    bucket = "gokulsnew-s3-us-east-2"
    key    = "dev/terraform.tfstate"
    region = "us-east-2"
    
    # Optional: Enable state locking
    # dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}