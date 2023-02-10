# Create the identity for our Github Actions to assume.
resource "chainguard_identity" "actions" {
  parent_id   = chainguard_group.user-group.id
  name        = "chainguard support"
  description = <<EOF
    This is an identity that authorizes the actions in this
    repository to assume to interact with chainctl.
  EOF

  claim_match {
    issuer  = "https://token.actions.githubusercontent.com"
    subject = "repo:mattmoor/terraform-playground:ref:refs/heads/main"
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "actions-identity" {
  value = chainguard_identity.actions.id
}



# Look up the viewer role to grant the actions identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the actions identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.actions.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
