# Create the identity for our Buildkite to assume.
resource "chainguard_identity" "buildkite" {
  parent_id   = chainguard_group.user-group.id
  name        = "buildkite"
  description = <<EOF
    This is an identity that authorizes Buildkite workflows
    for this repository to assume to interact with chainctl.
  EOF

  claim_match {
    issuer          = "https://agent.buildkite.com"
    subject_pattern = "organization:matts-fun-house:pipeline:enforce-buildkite-example:ref:refs/heads/main:commit:[0-9a-f]+:step:"
  }
}

# Emit the identity's ID so that we know what to assume in Buildkite.
output "buildkite-identity" {
  value = chainguard_identity.buildkite.id
}



# Look up the viewer role to grant the buildkite identity below.
data "chainguard_roles" "viewer" {
  name = "viewer"
}

# Grant the buildkite identity the "viewer" role on the demo group.
resource "chainguard_rolebinding" "view-stuff" {
  identity = chainguard_identity.buildkite.id
  group    = chainguard_group.user-group.id
  role     = data.chainguard_roles.viewer.items[0].id
}
