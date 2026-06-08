terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43"
    }
  }

  required_version = ">= 1.2"

  # tfstate para automatizar o deploy
  backend "s3" {
    bucket = "event-driven-terraform-state-gabriel-linhares"
    key    = "terraform.tfstate"
    region = "sa-east-1"
  }
}