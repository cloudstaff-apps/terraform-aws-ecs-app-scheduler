# terraform-aws-ecs-app-scheduler

[![Lint Status](https://github.com/DNXLabs/terraform-aws-ecs-app-scheduler/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-ecs-app-scheduler/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-ecs-app-scheduler)](https://github.com/DNXLabs/terraform-aws-ecs-app-scheduler/blob/master/LICENSE)

This terraform module is an AWS ECS Application Module for Scheduler without an Application Load Balancer(ALB), designed to be used with [DNXLabs/terraform-aws-ecs](https://github.com/DNXLabs/terraform-aws-ecs).

The following resources will be created:

 - IAM roles - The cloudwatch event needs an IAM Role to run the ECS task definition. A role is created and a policy will be granted via IAM policy.
 - IAM policy - Policy to be attached to the IAM Role. This policy will have a trust with the cloudwatch event service. And it will use the managed policy `AmazonEC2ContainerServiceEventsRole` created by AWS.
 - Cloudwatch Log Groups
      - You can specify the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653.
      - Export to a S3 Bucket - Whether to mark the log group to export to an S3 bucket (needs the module terraform-aws-log-exporter (https://github.com/DNXLabs/terraform-aws-log-exporter) to be deployed in the account/region)
 - ECS task definition - A task definition is required to run Docker containers in Amazon ECS. Some of the parameters you can specify in a task definition include:
      - Image - Docker image to deploy
           -  Default Value = "alpine:latest"
      - CPU - Hard limit of the CPU for the container
           -  Default Value = 0
      - Memory - Hard memory of the container
           -  Default Value = 512
      - Name - Name of the ECS Service
      - Set log configuration

 - ECS Task-scheduler activated by cloudwatch events
 - Cron expression - You can create rules that self-trigger on an automated schedule in CloudWatch Events using cron or rate expressions. All scheduled events use UTC time zone and the minimum precision for schedules is 1 minute.

## Resources

1. [Cloudwatch Events](#Cloudwatch-Events)
2. [Cron expression](#Cron-expression)
3. [IAM role](#Iam-Role)
4. [IAM policy](#IAM-Policy)
5. [Cloudwatch Log Group](#Cloudwatch-Log-Group)
6. [ECS task definition](#Task-Definition)

## Resources definition

### Cloudwatch Events

Amazon CloudWatch Events delivers a near real-time stream of system events that describe changes in Amazon Web Services (AWS) resources. Using simple rules that you can quickly set up, you can match events and route them to one or more target functions or streams. CloudWatch Events becomes aware of operational changes as they occur. CloudWatch Events responds to these operational changes and takes corrective action as necessary, by sending messages to respond to the environment, activating functions, making changes, and capturing state information.

[Cloudwatch Events documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html)

### Cron expression

You can create rules that self-trigger on an automated schedule in CloudWatch Events using cron or rate expressions. All scheduled events use UTC time zone and the minimum precision for schedules is 1 minute.

[Schedule expressions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)

### Iam Role

The cloudwatch event needs an IAM Role to run the ECS task definition. A role is created and a policy will be granted via IAM policy.

### IAM Policy

Policy to be attached to the IAM Role. This policy will have a trust with the cloudwatch event service. And it will use the managed policy `AmazonEC2ContainerServiceEventsRole` created by AWS.

### Cloudwatch Log Group

A log group is a group of log streams that share the same retention, monitoring, and access control settings. You can define log groups and specify which streams to put into each group. There is no limit on the number of log streams that can belong to one log group.

[Log Groups](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html)

### Task Definition

A task definition is required to run Docker containers in Amazon ECS. Some of the parameters you can specify in a task definition include:

- The Docker image to use with each container in your task
- How much CPU and memory to use with each task or each container within a task
- The launch type to use, which determines the infrastructure on which your tasks are hosted
- The Docker networking mode to use for the containers in your task
- The logging configuration to use for your tasks
- Whether the task should continue to run if the container finishes or fails
- The command the container should run when it is started
- Any data volumes that should be used with the containers in the task
- The IAM role that your tasks should use

[Task definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)

## Usage

```bash
module "example" {
  source               = "git::https://github.com/DNXLabs/terraform-aws-ecs-app-scheduler?ref=0.0.2"
  name                 = "example"
  vpc_id               = data.aws_vpc.selected.id # From DNXLabs/terraform-aws-ecs
  cluster_name         = module.ecs_apps.ecs_name # From DNXLabs/terraform-aws-ecs
  service_role_arn     = module.ecs_apps.ecs_service_iam_role_arn # From DNXLabs/terraform-aws-ecs
  task_role_arn        = module.ecs_apps.ecs_task_iam_role_arn # From DNXLabs/terraform-aws-ecs
  memory               = 512
  schedule_expression  = "0/30 * * * ? *" # it will trigger the task every 30 minutes https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  account_id           = var.aws_account_id
}
```

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_id | n/a | `any` | n/a | yes |
| cloudwatch\_logs\_export | Whether to mark the log group to export to an S3 bucket (needs terraform-aws-log-exporter to be deployed in the account/region) | `bool` | `false` | no |
| cloudwatch\_logs\_retention | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `120` | no |
| cluster\_name | n/a | `string` | `"Name of existing ECS Cluster to deploy this app to"` | no |
| cpu | Hard limit for CPU for the container | `string` | `"0"` | no |
| event\_description | n/a | `string` | `"ECS task"` | no |
| iam\_path | n/a | `string` | `"/"` | no |
| image | Docker image to deploy (can be a placeholder) | `string` | `"alpine:latest"` | no |
| launch\_type | Instance type. Fargate allowed | `string` | `"EC2"` | no |
| memory | Hard memory of the container | `string` | `"512"` | no |
| name | Name of your ECS service | `any` | n/a | yes |
| rule\_enabled | Whether the rule should be enabled | `bool` | `true` | no |
| schedule\_expression | Cron expression | `any` | n/a | yes |
| service\_role\_arn | Existing service role ARN created by ECS cluster module | `any` | n/a | yes |
| task\_role\_arn | Existing task role ARN created by ECS cluster module | `any` | n/a | yes |
| vpc\_id | VPC ID to deploy this app to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_log\_group\_arn | n/a |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-ecs-app-scheduler/blob/master/LICENSE) for full details.

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs_apps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy.ecs_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.ecs_events_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_cloudwatch_logs_export"></a> [cloudwatch\_logs\_export](#input\_cloudwatch\_logs\_export) | Whether to mark the log group to export to an S3 bucket (needs terraform-aws-log-exporter to be deployed in the account/region) | `bool` | `false` | no |
| <a name="input_cloudwatch_logs_retention"></a> [cloudwatch\_logs\_retention](#input\_cloudwatch\_logs\_retention) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `120` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"Name of existing ECS Cluster to deploy this app to"` | no |
| <a name="input_command"></a> [command](#input\_command) | The command passed to the container, exec form (e.g. ["node", "dist/scripts/run.js"]). Overrides the Docker image's default CMD. Leave unset to use the image's default command. | `list(string)` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Hard limit for CPU for the container | `string` | `"0"` | no |
| <a name="input_efs_access_point_gid"></a> [efs\_access\_point\_gid](#input\_efs\_access\_point\_gid) | Owner gid of the access point root directory. | `number` | `0` | no |
| <a name="input_efs_access_point_path"></a> [efs\_access\_point\_path](#input\_efs\_access\_point\_path) | Root directory on the EFS filesystem for this service's access point. Defaults to /<name>. Set it explicitly when several services must share one directory - two services pointing at the same path see the same files. | `string` | `null` | no |
| <a name="input_efs_access_point_permissions"></a> [efs\_access\_point\_permissions](#input\_efs\_access\_point\_permissions) | POSIX permissions applied to the access point root directory. | `string` | `"755"` | no |
| <a name="input_efs_access_point_uid"></a> [efs\_access\_point\_uid](#input\_efs\_access\_point\_uid) | Owner uid of the access point root directory. The default of 0 makes the mount read-only for a container running as a non-root user; set it to that user's uid when the container has to write. | `number` | `0` | no |
| <a name="input_efs_mapping"></a> [efs\_mapping](#input\_efs\_mapping) | A map of EFS filesystem ids to container mount paths, e.g. { fs-0abc123 = "/opt/airflow/custom\_config" }. Leave empty for no EFS volumes. | `map(string)` | `{}` | no |
| <a name="input_event_description"></a> [event\_description](#input\_event\_description) | n/a | `string` | `"ECS task"` | no |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path) | n/a | `string` | `"/"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to deploy (can be a placeholder) | `string` | `"alpine:latest"` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Instance type. Fargate allowed | `string` | `"EC2"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Hard memory of the container | `string` | `"512"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of your ECS service | `any` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host. (REQUIRED IF 'LAUNCH\_TYPE' IS FARGATE) | `any` | `null` | no |
| <a name="input_rule_enabled"></a> [rule\_enabled](#input\_rule\_enabled) | Whether the rule should be enabled | `bool` | `true` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Cron expression | `any` | n/a | yes |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | Existing service role ARN created by ECS cluster module | `any` | n/a | yes |
| <a name="input_ssm_variables"></a> [ssm\_variables](#input\_ssm\_variables) | Map of variables and SSM locations to add to the task definition | `map(string)` | `{}` | no |
| <a name="input_static_variables"></a> [static\_variables](#input\_static\_variables) | Map of variables and static values to add to the task definition | `map(string)` | `{}` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | Existing task role ARN created by ECS cluster module | `any` | n/a | yes |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | Container ulimit settings. This is a list of maps, where each map should contain "name", "hardLimit" and "softLimit" | <pre>list(object({<br>    name      = string<br>    hardLimit = number<br>    softLimit = number<br>  }))</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy this app to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudwatch_log_group_arn"></a> [aws\_cloudwatch\_log\_group\_arn](#output\_aws\_cloudwatch\_log\_group\_arn) | n/a |
<!-- END_TF_DOCS -->