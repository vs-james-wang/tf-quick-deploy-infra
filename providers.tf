terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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
