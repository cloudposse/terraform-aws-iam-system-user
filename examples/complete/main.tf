provider "aws" {
  region = var.region
}

data "aws_iam_policy_document" "deny" {
  statement {
    sid    = "DenyAll"
    effect = "Deny"

    actions   = ["*"]
    resources = ["*"]
  }
}

module "iam_system_user" {
  source = "../../"

  force_destroy         = true
  create_iam_access_key = var.create_iam_access_key
  inline_policies       = [data.aws_iam_policy_document.deny.json]
  ssm_enabled           = var.ssm_enabled
  ssm_base_path         = "/${module.this.id}"

  ssm_ses_smtp_password_enabled = var.ssm_ses_smtp_password_enabled

  context = module.this.context
}
