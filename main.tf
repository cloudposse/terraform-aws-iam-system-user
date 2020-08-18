module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  namespace   = var.namespace
  stage       = var.stage
  environment = var.environment
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags
  enabled     = var.enabled
}

# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  count         = var.enabled ? 1 : 0
  name          = module.label.id
  path          = var.path
  force_destroy = var.force_destroy
  tags          = module.label.tags
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  count = var.enabled ? 1 : 0
  user  = aws_iam_user.default[0].name
}

# policies -- inline and otherwise

locals {
  inline_policies_map = merge(
    var.inline_policies_map,
    { for i in var.inline_policies : md5(i) => i },
  )
  policy_arns_map = merge(
    var.policy_arns_map,
    { for i in var.policy_arns : i => i },
  )
}

resource "aws_iam_user_policy" "inline_policies" {
  for_each = var.enabled ? local.inline_policies_map : {}
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = module.label.id
  user        = join("", aws_iam_user.default.*.name)
  policy      = each.value
}

resource "aws_iam_user_policy_attachment" "policies" {
  for_each = var.enabled ? local.policy_arns_map : {}
  lifecycle {
    create_before_destroy = true
  }
  user       = join("", aws_iam_user.default.*.name)
  policy_arn = each.value
}
