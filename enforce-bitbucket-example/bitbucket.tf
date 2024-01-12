
# Create the identity for our Bitbucket to assume.
resource "chainguard_identity" "bitbucket" {
  parent_id   = chainguard_group.user-group.id
  name        = "bitbucket"
  description = <<EOF
    This is an identity that authorizes Bitbucket workflows
    for this repository to assume to interact with chainctl.
  EOF

  claim_match {
    issuer          = "https://api.bitbucket.org/2.0/workspaces/assumable-identities/pipelines-config/identity/oidc"
    subject_pattern = "{1d397906-81bf-459e-9a8d-eae79c0bc5f3}:.*"
    audience        = "ari:cloud:bitbucket::workspace/37f7aa0f-722b-4737-a1ba-74f42f300734"
  }
}

# Emit the identity's ID so that we know what to assume in Bitbucket.
output "bitbucket-identity" {
  value = chainguard_identity.bitbucket.id
}

# Look up the viewer role to grant the bitbucket identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the bitbucket identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.bitbucket.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
