provider "aws" {
  region = var.region
}

module "iam_system_user" {
  source        = "../../"
  namespace     = var.namespace
  stage         = var.stage
  name          = var.name
  force_destroy = true
}
