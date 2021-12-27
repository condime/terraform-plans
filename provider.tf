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
    path    = "condime/terraform_state"
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy = "condime/terraform-plans"
    }
  }
}

provider "random" {}
