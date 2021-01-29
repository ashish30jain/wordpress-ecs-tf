provider "aws" {
  region  = "us-east-1"
  profile = var.workspace
}

# Backend

terraform {
  required_version = ">=0.13.0"

  backend "local" {
      path = "ecs/default/terraform.tfstate"
  }
}

### Terraform linked projects ###

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
      path = "${path.module}/vpc/vpc/default/terraform.tfstate"
  }
}


data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
      path = "${path.module}/rds/rds/default/terraform.tfstate"
  }
}