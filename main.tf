# providers, terraform block, backend

terraform {
    required_version = ">= 1.11"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

#Configuring the AWS provider
provider "aws" {
    region = "us-east-1"

    default_tags {
        tags = {
            Project = "terraform-aws-project-canary"
            Environment = "development"
            ManagedBy = "terraform"
        }
    }
}