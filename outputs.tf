output "user_name" {
  value       = local.username
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = join("", aws_iam_user.default.*.arn)
  description = "The ARN assigned by AWS for this user"
}

output "user_unique_id" {
  value       = join("", aws_iam_user.default.*.unique_id)
  description = "The unique ID assigned by AWS"
}

output "ssm_enabled" {
  value       = local.ssm_enabled
  description = <<-EOT
    `true` when secrets are stored in SSM Parameter store,
    `false` when secrets are stored in Terraform state as outputs.
    EOT
}

output "access_key_id" {
  value       = local.create_iam_access_key ? aws_iam_access_key.default[0].id : null
  description = "The access key ID"
}

output "secret_access_key" {
  sensitive   = true
  value       = local.ssm_enabled ? null : join("", aws_iam_access_key.default.*.secret)
  description = <<-EOT
    When `ssm_enabled` is `false`, this is the secret access key for the IAM user.
    This will be written to the state file in plain-text.
    When `ssm_enabled` is `true`, this output will be empty to keep the value secure.
    EOT
}

output "ses_smtp_password_v4" {
  sensitive   = true
  value       = local.ssm_enabled ? null : join("", aws_iam_access_key.default.*.ses_smtp_password_v4)
  description = <<-EOT
    When `ssm_enabled` is false, this is the secret access key converted into an SES SMTP password
    by applying AWS's Sigv4 conversion algorithm. It will be written to the Terraform state file in plaintext.
    When `ssm_enabled` is `true`, this output will be empty to keep the value secure.
    EOT
}

output "access_key_id_ssm_path" {
  value       = local.ssm_enabled ? local.key_id_ssm_path : null
  description = "The SSM Path under which the IAM User's access key ID is stored"
}

output "secret_access_key_ssm_path" {
  value       = local.ssm_enabled ? local.secret_ssm_path : null
  description = "The SSM Path under which the IAM User's secret access key is stored"
}

output "ses_smtp_password_v4_ssm_path" {
  value       = local.ssm_enabled && var.ssm_ses_smtp_password_enabled ? local.smtp_password_ssm_path : null
  description = "The SSM Path under which the IAM User's SES SMTP password is stored"
}
