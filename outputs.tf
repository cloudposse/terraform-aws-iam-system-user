output "name" {
  value = "${aws_iam_user.default.name}"
}

output "unique_id" {
  value = "${aws_iam_user.default.unique_id}"
}

output "arn" {
  value = "${aws_iam_user.default.arn}"
}

output "access_key_id" {
  value = "${aws_iam_access_key.default.id}"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.default.id}"
}
