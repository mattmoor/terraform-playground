# Create the identity we will assume to push images from actions.
resource "chainguard_identity" "actions-publisher" {
  parent_id   = chainguard_group.public-repository.id
  name        = "actions publisher"
  description = <<EOF
    This is the identity that actions within:
       github.com/${local.github_user}/${local.github_repo}

    will assume to push container images to:
       ${chainguard_group.public-repository.id}
       ${chainguard_group.private-repository.id}
  EOF

  claim_match {
    issuer  = "https://token.actions.githubusercontent.com"
    subject = "repo:${local.github_user}/${local.github_repo}:ref:refs/heads/main"
  }
}

# Emit the identity's ID so that we know what to assume in actions.
output "push-identity" {
  value = chainguard_identity.actions-publisher.id
}




# Look up the id for the registry.push role within this environment.
data "chainguard_roles" "registry-push" {
  name = "registry.push"
}

# Grant the identity the "registry.push" role on our PUBLIC root group.
resource "chainguard_rolebinding" "push-public-stuff" {
  identity = chainguard_identity.actions-publisher.id
  group    = chainguard_group.public-repository.id
  role     = data.chainguard_roles.registry-push.items[0].id
}

# Grant the identity the "registry.push" role on our PRIVATE root group.
resource "chainguard_rolebinding" "push-private-stuff" {
  identity = chainguard_identity.actions-publisher.id
  group    = chainguard_group.private-repository.id
  role     = data.chainguard_roles.registry-push.items[0].id
}
