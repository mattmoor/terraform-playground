# Create the identity for our CircleCI job to assume.
resource "chainguard_identity" "circleci" {
  parent_id   = chainguard_group.user-group.id
  name        = "circleci job"
  description = <<EOF
    This is an identity that authorizes the CircleCI job
    in this repository to assume to interact with chainctl.
  EOF

  claim_match {
    issuer   = "https://oidc.circleci.com/org/1a9a4260-3ac3-45e5-9f19-4df788db4b5a"
    subject  = "org/1a9a4260-3ac3-45e5-9f19-4df788db4b5a/project/2a883f57-a107-4a6b-95d3-630364474913/user/76289a46-f83f-41c5-b637-67c8a9af6b34"
    audience = "1a9a4260-3ac3-45e5-9f19-4df788db4b5a"
  }
}

# Emit the identity's ID so that we know what to assume in circleci.
output "circleci-identity" {
  value = chainguard_identity.circleci.id
}



# Look up the viewer role to grant the circleci identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the circleci identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.circleci.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
