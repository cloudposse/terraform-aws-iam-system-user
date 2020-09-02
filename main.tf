# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  count         = module.this.enabled ? 1 : 0
  name          = module.this.id
  path          = var.path
  force_destroy = var.force_destroy
  tags          = module.this.tags
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  count = module.this.enabled ? 1 : 0
  user  = join("", aws_iam_user.default.*.name)
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
  for_each = module.this.enabled ? local.inline_policies_map : {}
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = module.this.id
  user        = join("", aws_iam_user.default.*.name)
  policy      = each.value
}

resource "aws_iam_user_policy_attachment" "policies" {
  for_each = module.this.enabled ? local.policy_arns_map : {}
  lifecycle {
    create_before_destroy = true
  }
  user       = join("", aws_iam_user.default.*.name)
  policy_arn = each.value
}
