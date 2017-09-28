module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

# Defines a user that should be able to write to you test bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.id}"
  path          = "${var.path}"
  force_destroy = "${var.force_destroy}"
}

# Generate API credentials
resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}


