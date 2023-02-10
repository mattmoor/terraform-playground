terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/aws-tenant"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

locals {
  # This is the Chainguard SaaS environment we're talking to.
  environment = "mattmoor.dev"

  # This is the Chainguard IAM group we'll operate within.
  group_id    = "2ce11ad0f8e3d7be751c70b9bfec8a2e3880cd09"
}

provider "chainguard" {
  console_api = "https://console-api.${local.environment}"
}

provider "google" {
  project = "mattmoor-chainguard"
}

provider "aws" {
  allowed_account_ids = ["979992218380"]
  region              = "us-west-2"
}

data "google_project" "project" {}
data "aws_caller_identity" "current" {}

# Configure GCP impersonation
module "gcp-association" {
  source = "chainguard-dev/chainguard-account-association/google"

  enforce_domain_name = local.environment
  enforce_group_id    = local.group_id
}

# Configure AWS impersonation
module "aws-association" {
  source = "chainguard-dev/chainguard-account-association/aws"

  enforce_domain_name = local.environment
  enforce_group_id    = local.group_id
}

# This is needed per-region where AWS resources run.
module "aws-association-auditlogs" {
  # The // here is semantic and tells terraform where
  # the repo/directory split is.
  source = "chainguard-dev/chainguard-account-association/aws//auditlogs"
}

resource "chainguard_account_associations" "example" {
  name  = "tbd"
  group = local.group_id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
  google {
    project_id = data.google_project.project.project_id
    project_number = data.google_project.project.number
  }
}

resource "chainguard_policy" "gke-trusted" {
  parent_id   = local.group_id
  description = "Mark the EKS images as trusted."
  document = jsonencode({
    apiVersion = "policy.sigstore.dev/v1beta1"
    kind       = "ClusterImagePolicy"
    metadata = {
      name = "eks-trusted"
    }
    spec = {
      images = [{
        glob = "602401143452.dkr.ecr.us-west-2.amazonaws.com/**"
      }]
      authorities = [{
        static = {
          action = "pass"
        }
      }]
    }
  })
}

