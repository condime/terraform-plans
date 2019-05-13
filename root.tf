terraform {
  backend "s3" {}
}

provider "aws" {}
provider "github" {}

module "geopoiesis-backend" {
  source = "github.com/geopoiesis/terraform//aws?ref=0.6.0"
  region = "eu-west-2"
}

module "geopoiesis-user" {
  source = "github.com/geopoiesis/terraform//aws/iam_user?ref=0.6.0"

  policy_arn = "${module.geopoiesis-backend.policy_arn}"
}

module "github" {
  source = "./github"
}
