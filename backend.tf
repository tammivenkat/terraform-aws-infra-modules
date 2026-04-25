terraform {
  backend "s3" {
    bucket         = "venkat-terraform-state-bucket-001"
    key            = "modules-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}
