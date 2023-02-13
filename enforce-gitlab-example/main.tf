terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/enforce-gitlab-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

provider "chainguard" {}
