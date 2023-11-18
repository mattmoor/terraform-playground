terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/images-k8s-cluster"
  }
}

provider "google" {
  project = "mattmoor-chainguard"
  region  = "us-central1"
}

resource "google_container_cluster" "pkg-build-cluster" {
  name     = "package-build-cluster"

  # To get arm nodes
  location = "us-central1"

  release_channel {
    channel = "RAPID"
  }

  // Workaround from:
  // https://github.com/hashicorp/terraform-provider-google/issues/10782
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  enable_autopilot = true

  timeouts {
    create = "30m"
    update = "40m"
  }
}
