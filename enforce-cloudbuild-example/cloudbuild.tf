# Create a service account for cloudbuild to use for assuming
# the Chainguard identity (below).
resource "google_service_account" "example" {
  project = local.project

  # This name must match what is in cloudbuild.yaml
  account_id = "enforce-cloudbuild-example"
}

data "google_project" "project" {}

# Authorize cloud build to assume our new service account.
resource "google_service_account_iam_binding" "allow_agentless_impersonation" {
  service_account_id = google_service_account.example.name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
}

# Create the identity for our Google Service Account to assume.
resource "chainguard_identity" "cloudbuild" {
  parent_id   = chainguard_group.user-group.id
  name        = "google cloud build"
  description = <<EOF
    This is an identity that authorizes a google service
    account used by cloud build to assume this identity.
  EOF

  claim_match {
    issuer  = "https://accounts.google.com"
    subject = google_service_account.example.unique_id
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "cloudbuild-identity" {
  value = chainguard_identity.cloudbuild.id
}

# Look up the viewer role to grant the cloudbuild identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the cloudbuild identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.cloudbuild.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
