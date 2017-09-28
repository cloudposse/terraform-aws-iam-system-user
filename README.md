# terraform-aws-iam-system-user

Terraform Module to Provion a basic IAM system user suitable for CI/CD Systems (E.g. TravisCI, CircleCI) or systems which are *external* to AWS that cannot leverage [AWS IAM Instance Profiles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html).

We do not recommend creating IAM users this way for any other purpose.

## Usage

```
module "circleci" {
  source     = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=master"
  namespace  = "cp"
  stage      = "circleci"
  name       = "assets"
}
```

## Variables

|  Name                          |  Default                          |  Description                                                                                                                    | Required |
|:-------------------------------|:---------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------|:--------:|
| `namespace`                    | ``                                | Namespace (e.g. `cp` or `cloudposse`)                                                                                           | No       |
| `stage`                        | ``                                | Stage (e.g. `prod`, `dev`, `staging`)                                                                                           | No       |
| `name`                         | ``                                | Name  (e.g. `bastion` or `db`)                                                                                                  | Yes      |
| `attributes`                   | `[]`                              | Additional attributes (e.g. `policy` or `role`)                                                                                 | No       |
| `force_destroy`                | `false`                           | Destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices.                                     | No       |
| `path`                         | `/`                               | Path in which to create the user                                                                                                | No       |

## Outputs

| Name                        | Description                                                                     |
|:----------------------------|:--------------------------------------------------------------------------------|
| `user_name`                 | Normalized IAM user name                                                        |
| `user_arn`                  | The ARN assigned by AWS for this user                                           |
| `user_unique_id`            | The unique ID assigned by AWS                                                   |
| `access_key_id`             | The access key ID                                                               |
| `secret_access_key`         | The secret access key. This will be written to the state file in plain-text     |

## License

Apache 2 License. See [`LICENSE`](LICENSE) for full details.
