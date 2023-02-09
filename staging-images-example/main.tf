terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/staging-images-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

locals {
  # This is the Chainguard SaaS environment we're talking to.
  environment = "chainops.dev"

  # This is where I will try pushing images from.
  github_user = "mattmoor"
  github_repo = "chainguard-registry-test"
}

provider "chainguard" {
  console_api = "https://console-api.${local.environment}"
}
