# Create the identity for our Gitlab CI to assume.
resource "chainguard_identity" "gitlab" {
  parent_id   = chainguard_group.user-group.id
  name        = "gitlab ci"
  description = <<EOF
    This is an identity that authorizes Gitlab CI in this
    repository to assume to interact with chainctl.
  EOF

  claim_match {
    issuer   = "https://gitlab.com"
    subject  = "project_path:mattmoor/terraform-playground:ref_type:branch:ref:main"
    audience = "https://gitlab.com"
  }
}

# Emit the identity's ID so that we know what to assume in Gitlab CI.
output "gitlab-identity" {
  value = chainguard_identity.gitlab.id
}



# Look up the viewer role to grant the gitlab identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the gitlab identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.gitlab.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
