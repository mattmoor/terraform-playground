terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/enforce-cricleci-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

provider "chainguard" {}
