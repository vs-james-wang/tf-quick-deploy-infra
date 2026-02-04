terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "sre-spin-up-test-resources"
    key     = "terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "sre-spin-up-ec2"
      owners      = "James Wang"
      Environment = "SRE-Ops-Lab"
      ManagedBy   = "terraform"
    }
  }
}
