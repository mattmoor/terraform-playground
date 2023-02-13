resource "ko_image" "example" {
  repo       = "gcr.io/${local.project}/staging-google-example"
  // TODO(mattmoor): We should publish a latest tag.
  base_image = "us.gcr.io/prod-enforce-fabc/chainctl:v0.1.71"
  importpath = "github.com/mattmoor/terraform-playground/staging-google-example"
}

# Create a service account for the example service to run as.
resource "google_service_account" "example" {
  project    = local.project
  account_id = "staging-google-example"
}

# Create the identity for our Cloud Run service to assume.
resource "chainguard_identity" "example" {
  parent_id   = chainguard_group.user-group.id
  name        = "cloud run gsa"
  description = <<EOF
    This is an identity for our Cloud Run Google Service
    Account to assume when interacting with our API.
  EOF

  claim_match {
    issuer  = "https://accounts.google.com"
    subject = google_service_account.example.unique_id
  }
}

resource "google_cloud_run_v2_service" "example" {
  name     = "staging-google-example"
  location = local.region

  template {
    service_account = google_service_account.example.email
    // The gen2 environment is required for ambient credential
    // detection to work.
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    containers {
      image = ko_image.example.image_ref
      env {
        name = "IDENTITY"
        value = chainguard_identity.example.id
      }
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

# Look up the viewer role to grant the example identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the example identity the "viewer" role on the
# demo group.
resource "chainguard_rolebinding" "view-user-stuff" {
  identity = chainguard_identity.example.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}

output "url" {
  value = google_cloud_run_v2_service.example.uri
}
