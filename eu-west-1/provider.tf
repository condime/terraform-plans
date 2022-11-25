terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    consul = {
      source = "hashicorp/consul"
    }
  }

  backend "consul" {
    address = "consul.condi.me"
    scheme  = "https"
    path    = "condime/terraform_state/eu-west-1"
  }
}

provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      ManagedBy = "condime/terraform-plans"
    }
  }
}

provider "consul" {
  address = "consul.condi.me:443"
  scheme  = "https"
}
