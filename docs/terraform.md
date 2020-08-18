## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0, < 0.14.0 |
| aws | ~> 2.0 |
| local | ~> 1.2 |
| null | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | `string` | `"-"` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| force\_destroy | Destroy the user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices | `bool` | `false` | no |
| inline\_policies | Inline policies to attach to our created user | `list(string)` | `[]` | no |
| inline\_policies\_map | Inline policies to attach (descriptive key => policy) | `map(string)` | `{}` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `""` | no |
| path | Path in which to create the user | `string` | `"/"` | no |
| policy\_arns | Policy ARNs to attach to our created user | `list(string)` | `[]` | no |
| policy\_arns\_map | Policy ARNs to attach (descriptive key => arn) | `map(string)` | `{}` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | `""` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | The access key ID |
| secret\_access\_key | The secret access key. This will be written to the state file in plain-text |
| ses\_smtp\_password\_v4 | The secret access key converted into an SES SMTP password by applying AWS's Sigv4 conversion algorithm |
| user\_arn | The ARN assigned by AWS for this user |
| user\_name | Normalized IAM user name |
| user\_unique\_id | The unique ID assigned by AWS |

