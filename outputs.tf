output "user_name" {
  value       = "${join("", aws_iam_user.default.*.name)}"
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = "${join("", aws_iam_user.default.*.arn)}"
  description = "The ARN assigned by AWS for this user"
}

output "role_name" {
  value       = "${join("", aws_iam_role.default.*.name)}"
  description = "Normalized IAM role attached to the user"
}

output "role_arn" {
  value       = "${join("", aws_iam_role.default.*.arn)}"
  description = "ARN IAM role attached to the user"
}

output "user_unique_id" {
  value       = "${join("", aws_iam_user.default.*.unique_id)}"
  description = "The unique ID assigned by AWS"
}

output "access_key_id" {
  value       = "${join("", aws_iam_access_key.default.*.id)}"
  description = "The access key ID"
}

output "secret_access_key" {
  value       = "${join("", aws_iam_access_key.default.*.secret)}"
  description = "The secret access key. This will be written to the state file in plain-text"
}
