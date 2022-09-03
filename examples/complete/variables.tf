variable "region" {
  type        = string
  description = "AWS region"
}

variable "create_iam_access_key" {
  type        = bool
  description = "Whether or not to create IAM access keys"
}

variable "ssm_enabled" {
  type        = bool
  description = "Set `true` to store secrets in SSM"
}

variable "ssm_ses_smtp_password_enabled" {
  type        = bool
  description = "Whether or not to create an SES SMTP password"
  default     = false
}
