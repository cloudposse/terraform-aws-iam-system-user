
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes |  | list | `<list>` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| force_destroy | Destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. | string | `false` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | - | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | - | yes |
| path | Path in which to create the user | string | `/` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')`) | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | The access key ID |
| secret_access_key | The secret access key. This will be written to the state file in plain-text |
| user_arn | The ARN assigned by AWS for this user |
| user_name | Normalized IAM user name |
| user_unique_id | The unique ID assigned by AWS |

