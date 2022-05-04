locals {
  username                   = join("", aws_iam_user.default.*.name)
  create_regular_access_key  = var.create_iam_access_key && var.iam_access_key_max_age == 0
  create_expiring_access_key = var.create_iam_access_key && var.iam_access_key_max_age > 0
  access_key                 = var.create_iam_access_key ? (local.create_regular_access_key ? aws_iam_access_key.default : awsutils_expiring_iam_access_key.default) : null
}

# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  count                = module.this.enabled ? 1 : 0
  name                 = module.this.id
  path                 = var.path
  force_destroy        = var.force_destroy
  tags                 = module.this.tags
  permissions_boundary = var.permissions_boundary
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  count = module.this.enabled && local.create_regular_access_key ? 1 : 0
  user  = local.username
}

resource "awsutils_expiring_iam_access_key" "default" {
  count   = module.this.enabled && local.create_expiring_access_key ? 1 : 0
  user    = local.username
  max_age = var.iam_access_key_max_age
}

# policies -- inline and otherwise
locals {
  inline_policies_map = merge(
    var.inline_policies_map,
    { for i in var.inline_policies : md5(i) => i }
  )
  policy_arns_map = merge(
    var.policy_arns_map,
    { for i in var.policy_arns : i => i }
  )
}

resource "aws_iam_user_policy" "inline_policies" {
  #bridgecrew:skip=BC_AWS_IAM_16:Skipping `Ensure IAM policies are attached only to groups or roles` check because this module intentionally attaches IAM policy directly to a user.
  for_each = module.this.enabled ? local.inline_policies_map : {}
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = module.this.id
  user        = local.username
  policy      = each.value
}

resource "aws_iam_user_policy_attachment" "policies" {
  #bridgecrew:skip=BC_AWS_IAM_16:Skipping `Ensure IAM policies are attached only to groups or roles` check because this module intentionally attaches IAM policy directly to a user.
  for_each = module.this.enabled ? local.policy_arns_map : {}
  lifecycle {
    create_before_destroy = true
  }
  user       = local.username
  policy_arn = each.value
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.9.1"

  count = module.this.enabled && var.ssm_enabled && var.create_iam_access_key ? 1 : 0

  parameter_write = concat([
    {
      name        = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/access_key_id"
      value       = join("", local.access_key.*.id)
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_ACCESS_KEY_ID for the ${local.username} user."
    },
    {
      name        = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/secret_access_key"
      value       = join("", local.access_key.*.secret)
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_SECRET_ACCESS_KEY for the ${local.username} user."
    }], var.ssm_ses_smtp_password_enabled ? [
    {
      name        = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/ses_smtp_password_v4"
      value       = join("", compact(local.access_key.*.ses_smtp_password_v4))
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_SECRET_ACCESS_KEY converted into an SES SMTP password for the ${local.username} user."
    }] : []
  )

  context = module.this.context
}
