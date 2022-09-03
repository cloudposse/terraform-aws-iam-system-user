variable "force_destroy" {
  type        = bool
  description = "Destroy the user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices"
  default     = false
}

variable "path" {
  type        = string
  description = "Path in which to create the user"
  default     = "/"
}

variable "inline_policies" {
  type        = list(string)
  description = "Inline policies to attach to our created user"
  default     = []
}

variable "inline_policies_map" {
  type        = map(string)
  description = "Inline policies to attach (descriptive key => policy)"
  default     = {}
}

variable "policy_arns" {
  type        = list(string)
  description = "Policy ARNs to attach to our created user"
  default     = []
}

variable "policy_arns_map" {
  type        = map(string)
  description = "Policy ARNs to attach (descriptive key => arn)"
  default     = {}
}

variable "permissions_boundary" {
  type        = string
  description = "Permissions Boundary ARN to attach to our created user"
  default     = null
}

variable "create_iam_access_key" {
  type        = bool
  description = "Whether or not to create IAM access keys"
  default     = true
}

variable "ssm_enabled" {
  type        = bool
  description = <<-EOT
    Set `true` to store secrets in SSM Parameter Store, `
    false` to store secrets in Terraform state as outputs.
    Since Terraform state would contain the secrets in plaintext,
    use of SSM Parameter Store is recommended.
    EOT
  default     = true
}

variable "ssm_ses_smtp_password_enabled" {
  type        = bool
  description = "Whether or not to create an SES SMTP password"
  default     = false
}

variable "ssm_base_path" {
  type        = string
  description = "The base path for SSM parameters where secrets are stored"
  default     = "/system_user/"
}
