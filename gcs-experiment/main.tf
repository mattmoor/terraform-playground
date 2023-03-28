terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/gcs-experiment"
  }
}

provider "google" {
  project = "mattmoor-chainguard"
}

resource "random_id" "id" {
  byte_length = 4
}

resource "google_storage_bucket" "example-bucket" {
  name          = "mattmoor-example-${random_id.id.hex}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "example-object" {
  name   = "example-object"
  bucket = google_storage_bucket.example-bucket.name
  content = <<EOF
    This is the object content I want to appear in GCS
  EOF
}

# Work around: https://github.com/hashicorp/terraform-provider-google/issues/14117
locals {
  qs_parts = split("&", split("?", google_storage_bucket_object.example-object.media_link)[1])
  values = {
    for token in local.qs_parts : split("=", token)[0] => split("=", token)[1]
  }
}

output "object-path" {
  value = "gs://${google_storage_bucket.example-bucket.name}/${google_storage_bucket_object.example-object.name}#${local.values["generation"]}"
}
