terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/staging-support-example"
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
}

provider "chainguard" {
  console_api = "https://console-api.${local.environment}"
}
