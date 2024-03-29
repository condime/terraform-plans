terraform {
  required_version = ">= 1.0"
  required_providers {
    consul = {
      source = "hashicorp/consul"
    }

    random = {
      source = "hashicorp/random"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  backend "consul" {
    address = "consul.condi.me"
    scheme  = "https"
    path    = "condime/terraform_state/eu-west-2"
  }
}

provider "aws" {
  region = var.region

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

provider "random" {}
