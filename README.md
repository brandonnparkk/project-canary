# Project Canary

AWS canary deployment infrastructure built with Terraform. Traffic splitting via ALB weighted target groups, multi-AZ EC2 instances, bastion host for SSH access, DynamoDB with a VPC gateway endpoint, and security group chaining for layered network security.

## Architecture Overview

![Architecture Diagram](./project-canary-final.svg)

The focus of this architecture was to build a resilient system that routes traffic to two separate application versions. To ensure high availability, the deployment spans two availability zones so that if one AZ goes down, the stable version continues serving from the surviving AZ.

Using ALB weighted target groups, 90% of traffic routes to the stable version and 10% to the canary. This allows a controlled rollout where the new version can be validated against real traffic before a full promotion.

The EC2 instances sit in private subnets with no direct internet access. Security group chaining ensures they only accept traffic from the ALB on port 80 and SSH from the bastion host. Responses flow back through the ALB to the end user.

## Tech Stack

- **IaC**: Terraform (~> 5.0 AWS provider)
- **Compute**: EC2 (Amazon Linux 2023)
- **Networking**: VPC, public/private subnets, Internet Gateway, ALB
- **Database**: DynamoDB (PAY_PER_REQUEST)
- **Security**: Security groups with chaining, IAM roles and instance profiles
- **Connectivity**: VPC Gateway Endpoint for DynamoDB

## Prerequisites

- AWS account with IAM permissions for VPC, EC2, ELB, DynamoDB, and IAM
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.11
- AWS CLI configured (`aws configure`)
- SSH key pair (`ssh-keygen -t ed25519`)

## Directory Structure

```
project-canary/
├── main.tf              # Providers, terraform block
├── variables.tf         # Input variables
├── outputs.tf           # ALB DNS name, bastion IP, private IPs
├── locals.tf            # Name prefix, shared tags
├── network.tf           # VPC, subnets, IGW, route tables, VPC endpoint
├── security.tf          # Security groups and rules
├── compute.tf           # EC2 instances, bastion, key pair
├── loadbalancer.tf      # ALB, target groups, listener with weighted routing
├── dynamodb.tf          # DynamoDB table
├── iam.tf               # IAM role, policy, instance profile
├── terraform.tfvars     # Variable values (gitignored)
└── .gitignore
```

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/<your-username>/project-canary.git
cd project-canary
```

2. Create `terraform.tfvars` with your values:

```hcl
my_ip_address = "YOUR_IP/32"
public_key    = "ssh-ed25519 AAAA..."
```

To find your IP, run `curl ifconfig.me`. Don't forget the `/32` suffix.

3. Initialize and deploy:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### SSH Access

Connect to the bastion host with agent forwarding, then jump to a private instance:

```bash
# Add your key to the SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# SSH to bastion
ssh -A -i ~/.ssh/id_ed25519 ec2-user@$(terraform output -raw bastion_host_public_ip)

# From the bastion, jump to a private instance
ssh ec2-user@<private_ip>
```

## Design Decisions

| Decision | Chose | Over | Why |
|---|---|---|---|
| Compute | EC2 | ECS Fargate, Lambda | Simpler, satisfies SSH requirement, lower cost for persistent server |
| Traffic splitting | ALB weighted target groups | Route 53 weighted routing | Layer 7, instant shifting, no DNS TTL delays |
| Admin access | Bastion host | SSM Session Manager | Free (vs ~$22/mo for 3 VPC interface endpoints) |
| DynamoDB connectivity | VPC Gateway Endpoint | NAT Gateway | Free, traffic stays on AWS backbone |
| Web server | Python http.server | Apache, Nginx | Pre-installed on AL2023, no internet needed in private subnets |
| DynamoDB billing | PAY_PER_REQUEST | Provisioned capacity | No traffic to forecast, free tier friendly |

For a full writeup on trade-offs and design rationale, see the [blog post](https://bpark.dev).

## Cleanup

Tear down all resources to avoid ongoing charges:

```bash
terraform destroy
```

## License

MIT