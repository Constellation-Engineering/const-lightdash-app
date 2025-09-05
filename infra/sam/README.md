# Constellation Lightdash - SAM Infrastructure

This directory contains an AWS SAM/CloudFormation template to provision the Lightdash infrastructure in a new AWS account:

- VPC with public and private subnets, NAT
- Application Load Balancer with TLS
- ECS Fargate cluster, task and service
- ECR repository
- RDS PostgreSQL instance
- Route53 DNS A-record
- GitHub OIDC provider and a deploy role for CI/CD

## Prerequisites

- AWS CLI and SAM CLI installed and configured
- An S3 bucket to store SAM artifacts (any region, same as deployment)
- An ACM certificate for your domain (same region as ALB)
- A Route53 hosted zone for your domain

## Parameters

See `parameters/sample.json` for an example. Minimum you need to provide:

- `ProjectName`: short name prefix (e.g. `const-lightdash`)
- `AwsRegion`: region (e.g. `us-east-1`)
- `DomainName`, `HostedZoneId`, `CertificateArn`

Optional networking, scaling and DB parameters have sensible defaults.

## Build and Deploy

From the repository root:

```bash
sam build --template-file infra/sam/template.yaml
sam deploy \
  --template-file infra/sam/template.yaml \
  --stack-name const-lightdash \
  --capabilities CAPABILITY_NAMED_IAM \
  --region <REGION> \
  --s3-bucket <SAM_ARTIFACTS_BUCKET> \
  --parameter-overrides file://infra/sam/parameters/sample.json
```

Outputs include the ECR repo URI, ECS cluster and service names, and the GitHub OIDC role you should use in CI.

## GitHub Actions CI/CD

The workflow `.github/workflows/deploy.yml` builds the image and deploys to ECS using OIDC.

Set repository variables (Settings → Variables → Actions):

- `AWS_REGION`: same region as the stack
- `ECR_REPOSITORY`: repository name created by the stack (e.g. `const-lightdash-app`)
- `ECS_CLUSTER`: cluster name output by the stack (e.g. `const-lightdash-cluster`)
- `ECS_SERVICE`: service name output by the stack (e.g. `const-lightdash-service`)

Set repository secrets:

- `AWS_OIDC_ROLE_ARN`: value of `GitHubDeployRoleArn` from the stack outputs

On push to `main`, the workflow builds an `linux/amd64` image, pushes `:latest` to ECR, and forces a new ECS deployment.

## Notes

- NAT Gateway is created in one AZ to reduce cost; for higher availability use two NATs.
- RDS deletion protection is enabled. To destroy the stack you must first disable it or snapshot/cleanup manually.
- Lightdash container environment variables include `PG*` and `LIGHTDASH_SECRET`. Add any additional variables you require by updating the task definition.

