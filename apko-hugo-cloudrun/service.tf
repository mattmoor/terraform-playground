# Create a service account for the example service to run as.
resource "google_service_account" "example" {
  project    = local.project
  account_id = "apko-hugo-cloudrun"
}

module "image" {
  source = "chainguard-dev/apko/publisher"

  target_repository = "gcr.io/${local.project}/apko-hugo-cloudrun"
  config            = file("${path.module}/apko.yaml")
}

// TODO: switch to oci_append when bugs are addressed
locals {
  bootstrap = <<EOF
  hugo new site quickstart
  cd quickstart
  git init
  git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke themes/ananke
  echo "theme = 'ananke'" >> config.toml
  /usr/bin/hugo server --bind 0.0.0.0 --port "$${PORT}"
  EOF
}

resource "google_cloud_run_v2_service" "example" {
  name     = "apko-hugo-cloudrun"
  location = local.region

  template {
    service_account = google_service_account.example.email
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    containers {
      image = module.image.image_ref
      command = ["/bin/sh", "-c", local.bootstrap]
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauths" {
  project  = local.project
  location = local.region
  service  = google_cloud_run_v2_service.example.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "url" {
  value = google_cloud_run_v2_service.example.uri
}
