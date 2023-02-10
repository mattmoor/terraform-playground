terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/staging-google-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
    ko = {
      source  = "ko-build/ko"
    }
  }
}

locals {
  # This is the Chainguard SaaS environment we're talking to.
  environment = "enforce.dev"

  project = "mattmoor-chainguard"
  region  = "us-west1"
}

provider "chainguard" {
  console_api = "https://console-api.${local.environment}"
}


provider "google" {
  project = local.project
  region  = local.region
}

provider "ko" {}