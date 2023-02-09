# Create the root group to host our images.
resource "chainguard_group" "public-repository" {
  name        = "mattmoor public images"
  description = "This group holds public images."
}

# Emit the group to make public
output "public-group" {
  value = chainguard_group.public-repository.id
}

# Look up the id for the registry.pull role within this environment.
data "chainguard_roles" "registry-pull" {
  name = "registry.pull"
}

# Create the identity we will assume to access "public" images.
resource "chainguard_identity" "all-users" {
  parent_id   = chainguard_group.public-repository.id
  name        = "all-users"
  description = <<EOF
    This is the identity that Enforce impersonates when it is
    pulling images associated with the "friendly name" for the
    group ${chainguard_group.public-repository.id}.
  EOF

  claim_match {
    issuer_pattern   = ".*"
    subject_pattern  = ".*"
    audience_pattern = ".*"
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "all-users" {
  value = chainguard_identity.all-users.id
}

# Grant the identity the "registry.pull" role on our public root group.
resource "chainguard_rolebinding" "pull-stuff" {
  identity = chainguard_identity.all-users.id
  group    = chainguard_group.public-repository.id
  role     = data.chainguard_roles.registry-pull.items[0].id
}
