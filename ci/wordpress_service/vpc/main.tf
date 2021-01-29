provider "aws" {
  region  = "us-east-1"
  profile = var.env
}

# Backend

terraform {
  required_version = ">=0.13.0"

  backend "local" {
      path = "vpc/default/terraform.tfstate"
  }
}

### Terraform linked projects ###