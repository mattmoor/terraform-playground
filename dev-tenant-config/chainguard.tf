locals {
  cgids = {
    "COSIGNED": "registry.pull",
    "INGESTER": "registry.pull",
  }
}

resource "chainguard_identity" "identities" {
  for_each = local.cgids

  parent_id   = local.group_id
  name        = lower(each.key)
  description = <<EOF
    This is the service principal identity that the Chainguard
    ${each.key} service will assume.  It has ${each.value} access
    to the group ${local.group_id}.
  EOF
  service_principal = each.key
}

data "chainguard_roles" "roles" {
  for_each = local.cgids
  name     = each.value
}

resource "chainguard_rolebinding" "grant-identity-role" {
  for_each = local.cgids
  identity = chainguard_identity.identities[each.key].id
  group    = local.group_id
  role     = data.chainguard_roles.roles[each.key].items[0].id
}

// Private images live in another group, so grant access to those as well.
resource "chainguard_rolebinding" "grant-identity-role-private-registry" {
  for_each = local.cgids
  identity = chainguard_identity.identities[each.key].id
  group    = chainguard_group.private.id
  role     = data.chainguard_roles.roles[each.key].items[0].id
}
