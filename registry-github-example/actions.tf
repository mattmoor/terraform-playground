# Create a root group for us to push image into.
resource "chainguard_group" "images-group" {
  name        = "example-images-group"
  description = <<EOF
    This group holds my private images.
  EOF
}

output "group-id" {
  value = chainguard_group.images-group.id
}

# Create the identity for our Github Actions to assume.
resource "chainguard_identity" "actions" {
  parent_id   = chainguard_group.images-group.id
  name        = "github actions"
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



# Look up the registry.push role to grant the actions identity below.
data "chainguard_roles" "pusher" {
  name = "registry.push"
}

# Grant the actions identity the "registry.push" role on the demo group.
resource "chainguard_rolebinding" "push-stuff" {
  identity = chainguard_identity.actions.id
  group    = chainguard_group.images-group.id
  role     = data.chainguard_roles.pusher.items[0].id
}
