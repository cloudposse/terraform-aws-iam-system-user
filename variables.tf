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
