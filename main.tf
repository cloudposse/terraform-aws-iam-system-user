module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.1"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "${var.enabled}"
}

# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  count         = "${var.enabled == "true" ? 1 : 0}"
  name          = "${module.label.id}"
  path          = "${var.path}"
  force_destroy = "${var.force_destroy}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  count = "${var.enabled == "true" ? 1 : 0}"
  user  = "${aws_iam_user.default.name}"
}
