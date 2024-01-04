terraform {
  backend "gcs" {
    bucket = "mattmoor-chainguard-terraform-state"
    prefix = "/per-customer-support-identities"
  }
  required_providers {
    chainguard = { source = "chainguard-dev/chainguard" }
  }
}

locals {
  # This is the Chainguard SaaS environment we're talking to.
  environment = "enforce.dev"
}

provider "chainguard" {
  console_api = "https://console-api.${local.environment}"
}

# Create a group to hold the support identities.
resource "chainguard_group" "support-group" {
  name        = "chainguard support"
  description = <<EOF
    This group holds per-customer support identities.
  EOF
}

locals {
  group_id = "FILL ME IN" // This should be the ID of a customer support group under @chainguard.dev

  customers = [
    "acme",
    "initech",
  ]
}

// Look up the membership in the support google group.
data "google_cloud_identity_group_memberships" "google-group" { group = local.group_id }

// Filter out the user member IDs.
locals {
  user_member_uids = [
    for member in data.google_cloud_identity_group_memberships.google-group.memberships :
    basename(member.name) if member.type == "USER"
  ]
}

resource "chainguard_identity" "support" {
  for_each = toset(local.customers)

  parent_id   = chainguard_group.support-group.id
  name        = "${each.key} support identity"
  description = <<EOF
    The chainguard support identity for customer ${each.key}.
  EOF

  claim_match {
    issuer          = "https://auth.chainguard.dev/"
    subject_pattern = "google-oauth2\\|(${join("|", local.user_member_uids)})"
  }
}

output "support-identities" {
  value = {
    for customer, identity in chainguard_identity.support : customer => identity.id
  }
}