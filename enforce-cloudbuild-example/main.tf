terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/enforce-cloudbuild-example"
  }
  required_providers {
    chainguard = {
      source = "chainguard/chainguard"
    }
  }
}

locals {
  project = "mattmoor-chainguard"
  region  = "us-west1"
}

provider "chainguard" {}


provider "google" {
  project = local.project
  region  = local.region
}
