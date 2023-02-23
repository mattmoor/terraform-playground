resource "chainguard_identity" "support" {
  parent_id   = local.group_id
  name        = "support role"
  description = <<EOF
    Simulate a support role on my account.
  EOF

  claim_match {
    issuer          = "https://auth.chainguard.dev/"
    subject_pattern = ".*"
  }
}

output "support-identity" {
  value = chainguard_identity.support.id
}

data "chainguard_roles" "viewer" {
  name = "viewer"
}

resource "chainguard_rolebinding" "support-stuff" {
  identity = chainguard_identity.support.id
  group    = local.group_id
  role     = data.chainguard_roles.viewer.items[0].id
}
