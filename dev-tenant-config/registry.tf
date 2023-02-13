# Create the root group in which the registry images will live.
resource "chainguard_group" "registry" {
  name        = "public images"
  description = "This group holds public images for registry.${local.environment}"
}

# Emit the group's ID so that it can be included in our config.
output "public-registry-group" {
  value = chainguard_group.registry.id
}

# Look up the id for the registry.pull role within this environment.
data "chainguard_roles" "registry-pull" {
  name = "registry.pull"
}

# Create the identity we will assume when accessing images within the public repository.
resource "chainguard_identity" "all-users" {
  parent_id   = chainguard_group.registry.id
  name        = "all-users"
  description = <<EOF
    This is the identity that the registry will assume when it accesses images within
    registry.${local.environment}/${chainguard_group.registry.id}.
  EOF

  # "public" is effectively determined by this claim-matching criteria, so we could do
  # fancier stuff here as well.
  claim_match {
    issuer_pattern   = ".*"
    subject_pattern  = ".*"
    audience_pattern = ".*"
  }
}

# Emit the identity's ID so that it can be included in our config.
output "pull-identity" {
  value = chainguard_identity.all-users.id
}

# Grant the identity the "registry.pull" role on our root group.
resource "chainguard_rolebinding" "pull-stuff" {
  identity = chainguard_identity.all-users.id
  group    = chainguard_group.registry.id
  role     = data.chainguard_roles.registry-pull.items[0].id
}




# Create a second private group, to test cross-repository mounting.
resource "chainguard_group" "private" {
  name        = "private images"
  description = "This group holds private images for registry.${local.environment}"
}

# Emit the group's ID so that we know where to push.
output "private-registry-group" {
  value = chainguard_group.private.id
}



# Look up the id for the registry.push role within this environment.
data "chainguard_roles" "registry-push" {
  name = "registry.push"
}

# Create the identity we will assume to push images from actions.
resource "chainguard_identity" "actions-publisher" {
  parent_id   = chainguard_group.registry.id
  name        = "actions publisher"
  description = <<EOF
    This is the identity that we will assume from github actions to publish images to
    registry.${local.environment}/${chainguard_group.registry.id}.
  EOF

  claim_match {
    issuer  = "https://token.actions.githubusercontent.com"
    subject = "repo:mattmoor/chainguard-registry-test:ref:refs/heads/main"
    # issuer_pattern  = ".*"
    # subject_pattern = ".*"
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "push-identity" {
  value = chainguard_identity.actions-publisher.id
}

# Grant the identity the "registry.push" role on our public group.
resource "chainguard_rolebinding" "push-public-stuff" {
  identity = chainguard_identity.actions-publisher.id
  group    = chainguard_group.registry.id
  role     = data.chainguard_roles.registry-push.items[0].id
}

# Grant the identity the "registry.push" role on our private group.
resource "chainguard_rolebinding" "push-private-stuff" {
  identity = chainguard_identity.actions-publisher.id
  group    = chainguard_group.private.id
  role     = data.chainguard_roles.registry-push.items[0].id
}
