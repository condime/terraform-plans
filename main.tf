resource "random_uuid" "uuid" {}

module "registry" {
  source = "./registry"
}
