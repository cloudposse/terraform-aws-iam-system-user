# terraform-aws-iam-system-user [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-iam-system-user.svg)](https://travis-ci.org/cloudposse/terraform-aws-iam-system-user)

Terraform Module to provision a basic IAM system user suitable for CI/CD Systems
(_e.g._ TravisCI, CircleCI) or systems which are *external* to AWS that cannot leverage [AWS IAM Instance Profiles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html).

We do not recommend creating IAM users this way for any other purpose.


## Usage

### Simple usage

```hcl
module "circleci" {
  source     = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=master"
  namespace  = "cp"
  stage      = "circleci"
  name       = "assets"
}
```

### Full usage

```hcl
data "aws_iam_policy_document" "fluentd_user_policy" {
  statement {
    actions = [
      "logs:DescribeDestinations",
      "logs:DescribeExportTasks",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeMetricFilters",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:GetLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:DeleteLogStream",
    ]

    resources = ["*"]
  }
}

module "fluentd_user" {
  source    = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=master"
  namespace = "cp"
  stage     = "dev"
  name      = "fluentd"
  policy    = "${data.aws_iam_policy_document.fluentd_user_policy.json}"
}
```


## Variables

| Name            | Default | Description                                                                                 | Required |
|:----------------|:-------:|:--------------------------------------------------------------------------------------------|:--------:|
| `namespace`     |   ``    | Namespace (e.g. `cp` or `cloudposse`)                                                       |    No    |
| `stage`         |   ``    | Stage (e.g. `prod`, `dev`, `staging`)                                                       |    No    |
| `name`          |   ``    | Name  (e.g. `bastion` or `db`)                                                              |   Yes    |
| `attributes`    |  `[]`   | Additional attributes (e.g. `policy` or `role`)                                             |    No    |
| `tags`          |  `{}`   | Additional tags  (e.g. `map("BusinessUnit","XYZ")`                                          |    No    |
| `delimiter`     |   `-`   | Delimiter to be used between `name`, `namespace`, `stage`, `arguments`, etc.                |    No    |
| `force_destroy` | `false` | Destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. |    No    |
| `path`          |   `/`   | Path in which to create the user                                                            |    No    |
| `enabled`       | `true`  | Flag for creation user                                                                      |    No    |
| `policy`        |   ``    | User policy in `json` format                                                                |    No    |


## Outputs

| Name                | Description                                                                 |
|:--------------------|:----------------------------------------------------------------------------|
| `user_name`         | Normalized IAM user name                                                    |
| `user_arn`          | The ARN assigned by AWS for this user                                       |
| `user_unique_id`    | The unique ID assigned by AWS                                               |
| `access_key_id`     | The access key ID                                                           |
| `secret_access_key` | The secret access key. This will be written to the state file in plain-text |


## License

Apache 2 License. See [`LICENSE`](LICENSE) for full details.
