output "user_name" {
  value = "${ var.enabled == "true" ? aws_iam_user.default.name : 0}"
}

output "user_arn" {
  value = "${aws_iam_user.default.arn}"
}

output "user_unique_id" {
  value = "${aws_iam_user.default.unique_id}"
}

output "access_key_id" {
  value = "${aws_iam_access_key.default.id}"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.default.secret}"
}
