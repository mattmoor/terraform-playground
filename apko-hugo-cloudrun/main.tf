terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/apko-hugo-cloudrun"
  }
  required_providers {
    apko = {
      source = "chainguard-dev/apko"
    }
  }
}

locals {
  project = "mattmoor-chainguard"
  region  = "us-west1"
}

provider "google" {
  project = local.project
  region  = local.region
}

provider "apko" {
  extra_repositories = ["https://packages.wolfi.dev/os"]
  extra_keyring      = ["https://packages.wolfi.dev/os/wolfi-signing.rsa.pub"]
  default_archs      = ["x86_64", "aarch64"]
  extra_packages     = ["wolfi-baselayout"]
}
