# Create the identity for Chainguard support to assume when
# inspecting your resources.
resource "chainguard_identity" "support" {
  parent_id   = chainguard_group.user-group.id
  name        = "chainguard support"
  description = <<EOF
    This is an identity for Chainguard support personel to
    assume if they need to interact with resources within
    the scopes it is authorized to access.
  EOF

  claim_match {
    issuer = "https://auth.chainguard.dev/"

    # This is intentionally wide open to allow folks to see
    # how this works.
    subject_pattern = ".*"
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "support-identity" {
  value = chainguard_identity.support.id
}




# Look up the viewer role to grant the support identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the support identity identity the "viewer" role on the
# demo group.
resource "chainguard_rolebinding" "view-user-stuff" {
  identity = chainguard_identity.support.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
