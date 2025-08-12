terraform {
  backend "s3" {
    bucket         = "zakaria-projects"
    key            = "ecs/terraformstate.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "ecsstatefile-lock"
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