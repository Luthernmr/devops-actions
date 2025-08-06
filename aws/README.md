# AWS DevOps Actions

This directory contains reusable GitHub Actions and workflows for AWS deployments.

## Actions

### deploy-ecs
Deploys a Docker image to AWS ECS service.

**Inputs:**
- `cluster_name`: Name of the ECS cluster
- `service_name`: Name of the ECS service
- `task_definition`: Path to task definition file or family name
- `image_uri`: URI of the Docker image to deploy
- `container_name`: Name of the container to update
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume
- `wait_for_stability`: Whether to wait for service stability (default: true)
- `auto_rollback_on_failure`: Automatically rollback on deployment failure (default: false)
- `rollback_timeout`: Timeout in minutes before triggering rollback (default: 10)
- `health_check_grace_period`: Grace period in seconds before health checks (default: 60)

### deploy-lambda
Deploys a Lambda function from zip file or source code.

**Inputs:**
- `function_name`: Name of the Lambda function
- `zip_file`: Path to zip file (optional)
- `s3_bucket`: S3 bucket containing code (optional)
- `s3_key`: S3 key of the code (optional)
- `source_directory`: Source directory to zip (optional)
- `runtime`: Lambda runtime
- `handler`: Function handler
- `environment_variables`: Environment variables as JSON
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume
- `timeout`: Function timeout in seconds
- `memory_size`: Function memory in MB

### deploy-lambda-docker
Deploys a Lambda function using a Docker container image.

**Inputs:**
- `function_name`: Name of the Lambda function
- `image_uri`: URI of the Docker image in ECR
- `environment_variables`: Environment variables as JSON
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume
- `timeout`: Function timeout in seconds
- `memory_size`: Function memory in MB
- `ephemeral_storage_size`: Ephemeral storage in MB
- `architecture`: Instruction set architecture (x86_64 or arm64)

### deploy-ecs-blue-green
Deploys a Docker image to AWS ECS using blue-green deployment strategy via CodeDeploy.

**Inputs:**
- `cluster_name`: Name of the ECS cluster
- `service_name`: Name of the ECS service
- `task_definition`: Path to task definition file or family name
- `image_uri`: URI of the Docker image to deploy
- `container_name`: Name of the container to update
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume
- `codedeploy_application_name`: Name of the CodeDeploy application
- `codedeploy_deployment_group`: Name of the CodeDeploy deployment group
- `codedeploy_config_name`: CodeDeploy configuration (default: CodeDeployDefault.ECSAllAtOnceBlueGreen)
- `wait_for_deployment`: Whether to wait for deployment completion (default: true)
- `deployment_timeout`: Timeout for deployment in minutes (default: 30)
- `auto_rollback_enabled`: Enable automatic rollback on failure (default: true)
- `termination_wait_time`: Wait time before terminating original tasks (default: 5)

### setup-codedeploy-ecs
Sets up CodeDeploy application and deployment group for ECS blue-green deployments.

**Inputs:**
- `application_name`: Name of the CodeDeploy application
- `deployment_group_name`: Name of the deployment group
- `ecs_cluster_name`: Name of the ECS cluster
- `ecs_service_name`: Name of the ECS service
- `load_balancer_target_group_arn`: ARN of the target group
- `production_listener_arn`: ARN of the production listener
- `test_listener_arn`: ARN of the test listener (optional)
- `codedeploy_service_role_arn`: ARN of the CodeDeploy service role
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume

### rollback-ecs
Rolls back an ECS service to a previous task definition revision.

**Inputs:**
- `cluster_name`: Name of the ECS cluster
- `service_name`: Name of the ECS service
- `rollback_to_revision`: Specific revision to rollback to (optional)
- `rollback_steps`: Number of revisions to rollback (default: 1)
- `aws_region`: AWS region
- `oidc_role_arn`: ARN of the IAM role to assume
- `wait_for_stability`: Whether to wait for service stability (default: true)
- `confirmation_required`: Require manual confirmation (default: false)
- `reason`: Reason for rollback (for auditing)

## Workflows

### deploy-ecs.yml
Reusable workflow for ECS deployments.

### deploy-ecs-blue-green.yml
Reusable workflow for ECS blue-green deployments using CodeDeploy.

### rollback-ecs.yml
Reusable workflow for ECS service rollbacks.

### deploy-lambda.yml
Reusable workflow for Lambda deployments.

### deploy-lambda-docker.yml
Reusable workflow for dockerized Lambda deployments.

## Usage Examples

### ECS Deployment
```yaml
jobs:
  deploy:
    uses: your-org/devops-actions/aws/workflows/deploy-ecs.yml@main
    with:
      cluster_name: my-cluster
      service_name: my-service
      task_definition: my-task-def
      image_uri: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
      container_name: my-container
      aws_region: us-east-1
    secrets:
      oidc_role_arn: ${{ secrets.ECS_OIDC_ROLE_ARN }}
```

### ECS Blue-Green Deployment
```yaml
jobs:
  deploy:
    uses: your-org/devops-actions/aws/workflows/deploy-ecs-blue-green.yml@main
    with:
      cluster_name: my-cluster
      service_name: my-service
      task_definition: my-task-def
      image_uri: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
      container_name: my-container
      aws_region: us-east-1
      codedeploy_application_name: my-app-codedeploy
      codedeploy_deployment_group: my-app-deployment-group
      codedeploy_config_name: CodeDeployDefault.ECSAllAtOnceBlueGreen
      wait_for_deployment: true
      environment: prod
    secrets:
      oidc_role_arn: ${{ secrets.ECS_BLUE_GREEN_OIDC_ROLE_ARN }}
```

### ECS Rollback
```yaml
jobs:
  rollback:
    uses: your-org/devops-actions/aws/workflows/rollback-ecs.yml@main
    with:
      cluster_name: my-cluster
      service_name: my-service
      rollback_steps: 1
      aws_region: us-east-1
      wait_for_stability: true
      reason: "Rolling back due to performance issues"
      environment: prod
    secrets:
      oidc_role_arn: ${{ secrets.ECS_OIDC_ROLE_ARN }}
```

### ECS Deployment with Auto-Rollback
```yaml
jobs:
  deploy:
    uses: your-org/devops-actions/aws/workflows/deploy-ecs.yml@main
    with:
      cluster_name: my-cluster
      service_name: my-service
      task_definition: my-task-def
      image_uri: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
      container_name: my-container
      aws_region: us-east-1
      auto_rollback_on_failure: true
      rollback_timeout: 15
      health_check_grace_period: 90
    secrets:
      oidc_role_arn: ${{ secrets.ECS_OIDC_ROLE_ARN }}
```

### Lambda Deployment (from source)
```yaml
jobs:
  deploy:
    uses: your-org/devops-actions/aws/workflows/deploy-lambda.yml@main
    with:
      function_name: my-function
      source_directory: ./src
      runtime: python3.9
      handler: app.handler
      aws_region: us-east-1
    secrets:
      oidc_role_arn: ${{ secrets.LAMBDA_OIDC_ROLE_ARN }}
```

### Dockerized Lambda Deployment
```yaml
jobs:
  deploy:
    uses: your-org/devops-actions/aws/workflows/deploy-lambda-docker.yml@main
    with:
      function_name: my-docker-function
      image_uri: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda:latest
      aws_region: us-east-1
      timeout: 120
      memory_size: 1024
    secrets:
      oidc_role_arn: ${{ secrets.LAMBDA_OIDC_ROLE_ARN }}
```

## Prerequisites

1. **OIDC Identity Provider**: Configure GitHub OIDC identity provider in AWS
2. **IAM Roles**: Create IAM roles with appropriate permissions for each service
3. **ECR Repository**: For dockerized deployments, ensure ECR repository exists
4. **Environment Secrets**: Configure required secrets in GitHub repository settings
5. **CodeDeploy Setup**: For blue-green deployments, CodeDeploy application and deployment groups must be configured
6. **Load Balancer**: Blue-green deployments require an Application Load Balancer with target groups

## Permissions Required

### ECS Deployment
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `ecs:DescribeTaskDefinition`
- `ecs:RegisterTaskDefinition`
- `iam:PassRole`

### ECS Blue-Green Deployment (additional permissions)
- `codedeploy:CreateDeployment`
- `codedeploy:GetApplication`
- `codedeploy:GetDeployment`
- `codedeploy:GetDeploymentConfig`
- `codedeploy:RegisterApplicationRevision`
- `s3:PutObject`
- `s3:GetObject`
- `s3:CreateBucket`
- `elbv2:DescribeTargetGroups`
- `elbv2:DescribeListeners`

### Lambda Deployment
- `lambda:UpdateFunctionCode`
- `lambda:UpdateFunctionConfiguration`
- `lambda:GetFunction`
- `s3:GetObject` (if using S3)

### Infrastructure Cost Estimation
- **Terraform State Access**: Read access to Terraform state storage
  - S3: `s3:GetObject`, `s3:ListBucket` (for S3 backend)
  - DynamoDB: `dynamodb:GetItem` (for state locking)
- **AWS Resource Discovery**: Read-only access for cost calculation
  - `pricing:GetProducts`
  - `pricing:DescribeServices`
  - `ec2:DescribeInstances`
  - `ec2:DescribeImages`
  - `rds:DescribeDBInstances`
  - `elasticloadbalancing:DescribeLoadBalancers`
  - Plus other read-only permissions for resources being estimated

### ECR Access (for Docker images)
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:BatchGetImage`

## Blue-Green Deployment Configurations

AWS CodeDeploy provides several predefined deployment configurations for ECS blue-green deployments:

### All-at-Once Deployments
- **CodeDeployDefault.ECSAllAtOnceBlueGreen**: Shifts all traffic at once from blue to green

### Linear Deployments
- **CodeDeployDefault.ECSLinear10PercentEvery1Minutes**: Shifts 10% of traffic every minute
- **CodeDeployDefault.ECSLinear10PercentEvery3Minutes**: Shifts 10% of traffic every 3 minutes

### Canary Deployments
- **CodeDeployDefault.ECSCanary10Percent5Minutes**: Shifts 10% of traffic, waits 5 minutes, then shifts remaining 90%
- **CodeDeployDefault.ECSCanary10Percent15Minutes**: Shifts 10% of traffic, waits 15 minutes, then shifts remaining 90%

### Setup Requirements for Blue-Green Deployments

1. **Application Load Balancer**: Required with at least one target group
2. **ECS Service**: Must be configured to use the load balancer
3. **CodeDeploy Application**: Must be created with ECS compute platform
4. **CodeDeploy Deployment Group**: Must be configured with:
   - ECS cluster and service
   - Load balancer information
   - IAM service role with appropriate permissions
5. **IAM Service Role**: CodeDeploy service role with permissions to:
   - Access ECS resources
   - Modify load balancer target groups
   - Create and manage Auto Scaling groups (if applicable)

### Example CodeDeploy Service Role Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:CreateTaskSet",
        "ecs:UpdateServicePrimaryTaskSet",
        "ecs:DeleteTaskSet",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:ModifyRule",
        "lambda:InvokeFunction",
        "cloudwatch:DescribeAlarms",
        "sns:Publish",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
```
