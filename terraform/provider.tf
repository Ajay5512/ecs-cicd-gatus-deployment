terraform {
  backend "s3" {
    bucket         = "gatus-tf-backend"
    key            = "ecs/terraformstate.tfstate"
    region         = "us-east-1"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.62.0"
    }
  }
}

provider "aws" {
  # Credentials will be added through git workflows via secrets
}
