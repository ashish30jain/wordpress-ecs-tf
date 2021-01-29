provider "aws" {
  region  = "us-east-1"
  profile = var.env
}

# Backend

terraform {
  required_version = ">=0.13.0"

  backend "local" {
      path = "rds/default/terraform.tfstate"
  }
}

### Terraform linked projects ###

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
      path = "../vpc/vpc/default/terraform.tfstate"
  }
}