terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/registry-github-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

provider "chainguard" {}
