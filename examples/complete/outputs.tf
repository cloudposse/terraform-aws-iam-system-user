output "user_name" {
  value       = module.iam_system_user.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.iam_system_user.user_arn
  description = "IAM user ARN"
}

output "user_unique_id" {
  value       = module.iam_system_user.user_unique_id
  description = "IAM user unique ID assigned by AWS"
}
