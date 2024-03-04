locals {
  enabled = module.this.enabled

  username              = join("", aws_iam_user.default.*.name)
  create_iam_access_key = local.enabled && var.create_iam_access_key
  ssm_enabled           = var.ssm_enabled && local.create_iam_access_key

  key_id_ssm_path        = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/access_key_id"
  secret_ssm_path        = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/secret_access_key"
  smtp_password_ssm_path = "${trimsuffix(var.ssm_base_path, "/")}/${local.username}/ses_smtp_password_v4"
}

# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  count                = local.enabled ? 1 : 0
  name                 = module.this.id
  path                 = var.path
  force_destroy        = var.force_destroy
  tags                 = module.this.tags
  permissions_boundary = var.permissions_boundary
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  count = local.create_iam_access_key ? 1 : 0
  user  = local.username
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

resource "aws_iam_user_group_membership" "default" {
  count  = module.this.enabled && length(var.groups) > 0 ? 1 : 0
  user   = local.username
  groups = var.groups
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  count = local.ssm_enabled ? 1 : 0

  parameter_write = concat([
    {
      name        = local.key_id_ssm_path
      value       = aws_iam_access_key.default[0].id
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_ACCESS_KEY_ID for the ${local.username} user."
    },
    {
      name        = local.secret_ssm_path
      value       = aws_iam_access_key.default[0].secret
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_SECRET_ACCESS_KEY for the ${local.username} user."
    }], var.ssm_ses_smtp_password_enabled ? [
    {
      name        = local.smtp_password_ssm_path
      value       = aws_iam_access_key.default[0].ses_smtp_password_v4
      type        = "SecureString"
      overwrite   = true
      description = "The AWS_SECRET_ACCESS_KEY converted into an SES SMTP password for the ${local.username} user."
    }] : []
  )

  context = module.this.context
}
