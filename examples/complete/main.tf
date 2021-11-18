provider "aws" {
  region = var.region
}

# provider "awsutils" {
#   region = var.region
# }

module "iam_system_user" {
  source = "../../"

  force_destroy = true

  context = module.this.context
}
