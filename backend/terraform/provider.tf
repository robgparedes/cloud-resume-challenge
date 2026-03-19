terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "robgparedes-cloudresume-tfstate-490058394460-ap-southeast-2-an"
    key            = "backend/terraform.tfstate"
    region         = "ap-southeast-2"
    use_lockfile   = true
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}